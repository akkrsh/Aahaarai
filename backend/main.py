from fastapi import FastAPI, File, UploadFile
import uvicorn
import google.generativeai as genai
from PIL import Image
import io

app = FastAPI()

# --- CONFIGURATION ---
# TODO: PASTE YOUR GOOGLE API KEY HERE
API_KEY = "AIzaSyCq2Ve3H6p_Iq5mRxTLuqM6yaqXb7a_xg8" 
genai.configure(api_key=API_KEY)

# Use 'gemini-1.5-flash' if 2.0 gives errors
model = genai.GenerativeModel('gemini-2.0-flash-exp')

@app.get("/")
def home():
    return {"status": "AahaarAI Google Server Online"}

@app.post("/analyze")
async def analyze_food(file: UploadFile = File(...)):
    try:
        print("Received image... Sending to Google Gemini...")
        
        image_bytes = await file.read()
        image = Image.open(io.BytesIO(image_bytes))

        # UPDATED PROMPT: Added 'Suggestion' field
        prompt = """
        Analyze this food image. Provide a strict response in this exact format:
        Dish: [Name of Dish]
        Calories: [Number only, e.g. 250]
        Protein: [Number only, e.g. 10]
        Carbs: [Number only, e.g. 30]
        Fat: [Number only, e.g. 15]
        Fiber: [Number only, e.g. 5]
        Verdict: [1 sentence health verdict]
        Suggestion: [1 specific tip to make THIS meal healthier, e.g., "Add a side of cucumber salad to balance the oil."]
        """

        response = model.generate_content([prompt, image])
        print("Analysis Result:\n" + response.text)
        return {"result": response.text}

    except Exception as e:
        print(f"Error: {e}")
        return {"result": "Dish: Error\nSuggestion: Please try again."}

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)