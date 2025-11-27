FROM python:3.11-slim

WORKDIR /app

# install dependencies
COPY requirements.txt /app/
RUN pip install --no-cache-dir -r requirements.txt

COPY app.py /app/

# expose the port that Flask listens on
EXPOSE 12144

# run the app
CMD ["python", "app.py"]
