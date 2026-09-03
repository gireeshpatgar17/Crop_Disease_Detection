import io
import os
import time
import uuid
import numpy as np
from PIL import Image

# Ensure PyTorch backend for Keras
os.environ["KERAS_BACKEND"] = "torch"
import keras
from dotenv import load_dotenv
from fastapi import FastAPI, File, HTTPException, UploadFile
from fastapi.middleware.cors import CORSMiddleware
from supabase import Client, create_client

# Load database environment variables from backend/database/.env
ENV_PATH = os.path.join(os.path.dirname(__file__), "database", ".env")
if os.path.exists(ENV_PATH):
    load_dotenv(ENV_PATH)

SUPABASE_URL = os.getenv("SUPABASE_URL")
SUPABASE_KEY = os.getenv("SUPABASE_SECRET_KEY") or os.getenv("SUPABASE_PUBLISHABLE_KEY")
STORAGE_BUCKET = "disease-images"

supabase: Client | None = None
if SUPABASE_URL and SUPABASE_KEY:
    try:
        supabase = create_client(SUPABASE_URL, SUPABASE_KEY)
        print("Connected to Supabase database successfully.")
    except Exception as e:
        print("Warning: Could not connect to Supabase:", e)

app = FastAPI(title="Smart Agriculture - Crop Disease Detection API")

# Allow CORS for Flutter mobile/web/desktop
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Disease Classes (sorted alphabetically as trained in standard Keras flow)
CLASS_NAMES = [
    "Brown Spot",
    "Healthy",
    "Leaf Blast",
    "Sheath Blight",
]

DISEASE_ADVICE = {
    "Healthy": {
        "status": "Healthy",
        "symptoms": "Leaves are vibrant green with uniform color and no visible lesions, spots, or wilting.",
        "cause": "None - healthy crop foliage.",
        "treatment": "No treatment needed. Continue standard agronomic schedule.",
        "prevention": "Maintain regular field monitoring, balanced fertilization, and proper water management.",
        "recommendation": "Your crop appears healthy with no signs of disease. Maintain standard field monitoring, adequate irrigation, and balanced nutrient supply.",
    },
    "Brown Spot": {
        "status": "Diseased",
        "symptoms": "Small, circular to oval dark-brown lesions with gray or whitish centers across leaf surfaces.",
        "cause": "Fungal pathogen Bipolaris oryzae. Often associated with nutrient-deficient soil.",
        "treatment": "Foliar spray with Mancozeb (2g/L), Edifenphos (1ml/L), or Propiconazole (1ml/L).",
        "prevention": "Apply balanced NPK with adequate potassium, zinc, and organic matter. Treat seeds with fungicide before planting.",
        "recommendation": "Brown Spot detected (caused by Bipolaris oryzae). Ensure adequate potassium and zinc fertilization. If symptoms persist or spread, apply Mancozeb (2g/L) or Edifenphos (1ml/L).",
    },
    "Leaf Blast": {
        "status": "Diseased",
        "symptoms": "Spindle-shaped or diamond-shaped lesions with gray/white necrotic centers and dark reddish-brown borders.",
        "cause": "Fungal pathogen Magnaporthe oryzae (Pyricularia oryzae). Proliferates under high humidity and excessive nitrogen.",
        "treatment": "Spray Tricyclazole 75% WP (0.6g/L) or Isoprothiolane 40% EC (1.5ml/L) or Kasugamycin (2ml/L).",
        "prevention": "Avoid excess nitrogen application; split nitrogen doses. Maintain proper field water level and plant blast-resistant varieties.",
        "recommendation": "Leaf Blast detected (caused by Magnaporthe oryzae). Avoid excessive nitrogen fertilizer. Maintain standing water in the field. Spray Tricyclazole 75 WP (0.6 g/L) or Isoprothiolane (1.5 ml/L).",
    },
    "Sheath Blight": {
        "status": "Diseased",
        "symptoms": "Oval or irregular greenish-gray water-soaked lesions on leaf sheaths near the water line, spreading upward with dark brown margins.",
        "cause": "Soil-borne fungal pathogen Rhizoctonia solani. Favored by high planting density and humid weather.",
        "treatment": "Apply Hexaconazole 5% EC (2ml/L), Validamycin 3% L (2.5ml/L), or Azoxystrobin (1ml/L) directed at the plant base.",
        "prevention": "Ensure wider plant spacing for aeration, remove infected crop residues, and avoid excessive nitrogen fertilization.",
        "recommendation": "Sheath Blight detected (caused by Rhizoctonia solani). Remove weeds and improve field aeration. Apply Hexaconazole 5% EC (2 ml/L) or Validamycin 3% L (2.5 ml/L) directed at the plant base.",
    },
}

MODEL_PATH = os.path.join(os.path.dirname(__file__), "models", "FinalTest_inceptionv3.h5")
model = None


def get_model():
    global model
    if model is None:
        if not os.path.exists(MODEL_PATH):
            raise RuntimeError(f"Model file not found at: {MODEL_PATH}")
        print(f"Loading Crop Disease model from {MODEL_PATH}...")
        model = keras.models.load_model(MODEL_PATH, compile=False)
        print("Model loaded successfully!")
    return model


def ensure_storage_bucket():
    """Ensure the public storage bucket exists in Supabase."""
    if supabase:
        try:
            buckets = [b.name for b in supabase.storage.list_buckets()]
            if STORAGE_BUCKET not in buckets:
                supabase.storage.create_bucket(STORAGE_BUCKET, options={"public": True})
                print(f"Created public Supabase storage bucket: {STORAGE_BUCKET}")
        except Exception as e:
            print("Storage bucket check note:", e)


# Warm up model and ensure storage on startup
@app.on_event("startup")
def startup_event():
    try:
        get_model()
    except Exception as e:
        print("Warning: Could not pre-load model on startup:", e)
    ensure_storage_bucket()


@app.get("/")
def read_root():
    return {
        "message": "Smart Agriculture Disease Detection API is running",
        "classes": CLASS_NAMES,
        "database_connected": supabase is not None,
        "storage_bucket": STORAGE_BUCKET,
    }


@app.get("/health")
def health_check():
    return {
        "status": "online",
        "model_loaded": model is not None,
        "database_connected": supabase is not None,
        "storage_bucket": STORAGE_BUCKET,
        "classes": CLASS_NAMES,
    }


def preprocess_image(image_bytes: bytes) -> np.ndarray:
    """Preprocesses image bytes to (1, 224, 224, 3) normalized for InceptionV3."""
    img = Image.open(io.BytesIO(image_bytes)).convert("RGB")
    img = img.resize((224, 224), Image.Resampling.BILINEAR)
    img_array = np.array(img, dtype=np.float32)
    # InceptionV3 standard normalization: scale pixels to [-1, 1]
    img_array = (img_array / 127.5) - 1.0
    img_array = np.expand_dims(img_array, axis=0)
    return img_array


@app.post("/disease/predict")
async def predict_disease(
    file: UploadFile = File(...),
    farm_id: int = 1,
):
    """
    Predicts crop disease from uploaded leaf image, uploads the image to Supabase Storage,
    and records detection metadata into Supabase public.disease_history.
    """
    try:
        contents = await file.read()
        if not contents:
            raise HTTPException(status_code=400, detail="Empty image uploaded.")

        # 1. Upload leaf image to Supabase Storage
        image_url = None
        if supabase:
            try:
                ext = "jpg"
                if file.filename and "." in file.filename:
                    parsed_ext = file.filename.rsplit(".", 1)[-1].lower()
                    if parsed_ext in ["jpg", "jpeg", "png", "webp"]:
                        ext = parsed_ext

                file_path = f"farm_{farm_id}/{int(time.time())}_{uuid.uuid4().hex[:6]}.{ext}"
                content_type = file.content_type or f"image/{ext}"

                supabase.storage.from_(STORAGE_BUCKET).upload(
                    file_path,
                    contents,
                    file_options={"content-type": content_type},
                )
                image_url = supabase.storage.from_(STORAGE_BUCKET).get_public_url(file_path)
                print(f"Uploaded leaf image to Supabase Storage: {image_url}")
            except Exception as upload_err:
                print("Warning: Could not upload image to Supabase storage:", upload_err)

        # 2. Preprocess image
        input_data = preprocess_image(contents)

        # 3. Run inference
        net = get_model()
        preds = net.predict(input_data)

        # Output handling: Model produces ['disease_class', 'disease_scale']
        if isinstance(preds, (list, tuple)):
            class_probs = np.array(preds[0])[0]
            scale_val = float(np.array(preds[1])[0][0]) if len(preds) > 1 else 0.0
        elif isinstance(preds, dict):
            class_probs = np.array(preds.get("disease_class"))[0]
            scale_val = float(np.array(preds.get("disease_scale"))[0][0])
        else:
            class_probs = np.array(preds)[0]
            scale_val = 0.0

        top_idx = int(np.argmax(class_probs))
        confidence = float(class_probs[top_idx])
        predicted_disease = CLASS_NAMES[top_idx]

        # Clamp scale to sensible display range (0.0 to 5.0, or absolute positive)
        scale_val = round(max(0.0, scale_val), 2)

        info = DISEASE_ADVICE.get(
            predicted_disease,
            {
                "status": "Unknown",
                "symptoms": "Unidentified symptom pattern.",
                "cause": "Unknown pathogen or stress condition.",
                "treatment": "Consult a local agricultural extension specialist.",
                "prevention": "Follow standard crop management guidelines.",
                "recommendation": "Consult a local agricultural extension specialist for diagnosis.",
            },
        )

        all_probs = {
            CLASS_NAMES[i]: round(float(class_probs[i]), 4)
            for i in range(len(CLASS_NAMES))
        }

        # 4. Save detection to Supabase public.disease_history table
        saved_id = None
        if supabase:
            try:
                db_record = {
                    "farm_id": farm_id,
                    "disease_name": predicted_disease,
                    "confidence": round(confidence * 100, 2),
                    "image_url": image_url,
                    "symptoms": info.get("symptoms"),
                    "cause": info.get("cause"),
                    "treatment": info.get("treatment"),
                    "prevention": info.get("prevention"),
                }
                res = supabase.table("disease_history").insert(db_record).execute()
                if res.data and len(res.data) > 0:
                    saved_id = res.data[0].get("id")
                    print(f"Recorded in Supabase disease_history: id={saved_id} (farm_id={farm_id}, image_url={image_url})")
            except Exception as db_err:
                print("Warning: Could not insert record into Supabase disease_history:", db_err)

        return {
            "success": True,
            "id": saved_id,
            "farm_id": farm_id,
            "disease": predicted_disease,
            "confidence": round(confidence, 4),
            "scale": scale_val,
            "status": info["status"],
            "image_url": image_url,
            "symptoms": info.get("symptoms"),
            "cause": info.get("cause"),
            "treatment": info.get("treatment"),
            "prevention": info.get("prevention"),
            "recommendation": info["recommendation"],
            "all_predictions": all_probs,
            "saved_to_db": saved_id is not None,
        }

    except Exception as e:
        print("Prediction error:", e)
        raise HTTPException(status_code=500, detail=str(e))


@app.get("/disease/history")
def get_disease_history(farm_id: int = 1, limit: int = 20):
    """Retrieves past disease detection history from Supabase."""
    if not supabase:
        raise HTTPException(status_code=503, detail="Supabase database not connected.")
    try:
        res = (
            supabase.table("disease_history")
            .select("*")
            .eq("farm_id", farm_id)
            .order("detected_at", desc=True)
            .limit(limit)
            .execute()
        )
        return {"success": True, "farm_id": farm_id, "data": res.data}
    except Exception as e:
        print("Error fetching disease history:", e)
        raise HTTPException(status_code=500, detail=str(e))


if __name__ == "__main__":
    import uvicorn
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)