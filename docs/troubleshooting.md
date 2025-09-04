# Troubleshooting

## JVM not starting (Py4JJavaError)

- Symptom: `An error occurred while calling None.org.apache.spark.api.java.JavaSparkContext`
- Fix: Install JDK 11 and set `JAVA_HOME`; verify `java -version` shows 11.x

## Spark driver cannot bind port

- Symptom: `Service 'sparkDriver' could not bind on a random free port`
- Fix: We force IPv4/localhost in `get_spark()`; restart kernel and retry

## ModuleNotFoundError: bluebrick in notebooks

- Use the provided first cell in `00_quickstart_etl.ipynb` which adds `src/` to `sys.path`
- Ensure the dev workflow uploads/uses code from GitHub via the bundle

## YAML lint failures

- Ensure `---` document start at the top of YAML files
- Keep line length within configured limits; wrap long commands

## Ruff configuration warnings

- We use `[tool.ruff.lint.*]` sections; run `ruff src tests` to verify

## ADF Git integration not visible

- Ensure `enable_adf_github=true` and Git variables are set in tfvars or workflow env
- Confirm ADF was created/applied successfully and that you are in the correct environment subscription

