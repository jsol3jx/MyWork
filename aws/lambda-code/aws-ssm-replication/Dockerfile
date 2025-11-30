# Image must match your target architecture; this is x86_64 by default.
FROM public.ecr.aws/lambda/python:3.11

# Optional: install deps (keep empty if not needed)
COPY requirements.txt .
RUN python -m pip install --no-cache-dir -r requirements.txt -t ${LAMBDA_TASK_ROOT}

# Add your function code
COPY src/ ${LAMBDA_TASK_ROOT}

# Set the handler (module.function)
CMD ["app.lambda_handler"]