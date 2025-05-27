import pandas as pd
from sklearn.ensemble import RandomForestRegressor
from sklearn.model_selection import train_test_split
from sklearn.metrics import root_mean_squared_error
import mlflow
import mlflow.sklearn


def train(df: pd.DataFrame, target_column: str = "target") -> RandomForestRegressor:
    """
    Train a RandomForest model on the given DataFrame.

    Args:
        df: DataFrame with features and target
        target_column: Name of the column to predict

    Returns:
        Trained RandomForestRegressor model
    """
    # Prepare features and target
    X = df.drop(columns=[target_column])
    y = df[target_column]

    # Split into train/test
    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

    # Start MLflow run
    with mlflow.start_run():
        # Define model
        model = RandomForestRegressor(n_estimators=100, random_state=42)
        model.fit(X_train, y_train)

        # Predict and evaluate
        predictions = model.predict(X_test)
        rmse = root_mean_squared_error(y_test, predictions, squared=False)

        # Log parameters and metrics
        mlflow.log_param("n_estimators", 100)
        mlflow.log_metric("rmse", rmse)

        # Log model
        mlflow.sklearn.log_model(model, "model")

    return model