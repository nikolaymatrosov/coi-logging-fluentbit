FROM python:3.10

WORKDIR /usr/src/app

#COPY requirements.txt ./
#RUN pip install --no-cache-dir -r requirements.txt

COPY logs.py .

CMD [ "python", "./logs.py" ]