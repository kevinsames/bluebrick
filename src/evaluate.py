import pandas as pd
from sklearn.metrics import mean_squared_error, r2_score
import mlflow
import joblib
import os


def evaluate_model(model, X_test: pd.DataFrame, y_test: pd.Series) -> dict:
    """
    Evaluate a trained model using RMSE and R² score.
    Logs metrics to MLflow.

    Parameters:
        model: trained model
        X_test (pd.DataFrame): test features
        y_test (pd.Series): true values

    Returns:
        dict: Dictionary with RMSE and R² scores
    """
    predictions = model.predict(X_test)

    rmse = mean_squared_error(y_test, predictions, squared=False)
    r2 = r2_score(y_test, predictions)

    mlflow.log_metric("rmse", rmse)
    mlflow.log_metric("r2_score", r2)

    return {"rmse": rmse, "r2_score": r2}


def load_model(model_path: str):
    """
    Load a model from a local path or artifact.

    Parameters:
        model_path (str): Path to the saved model (e.g., MLflow artifact URI)

    Returns:
        Loaded model
    """
    if not os.path.exists(model_path):
        raise FileNotFoundError(f"Model path not found: {model_path}")
    return joblib.load(model_path)