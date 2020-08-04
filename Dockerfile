FROM alpine:latest
RUN apk update && apk upgrade && apk add --no-cache bash python3 redis ffmpeg
RUN python3 -m ensurepip
RUN pip3 install --upgrade pip && pip3 install pipenv gunicorn
RUN mkdir /media/in && mkdir /media/out && mkdir /media/config && mkdir /app

COPY Pipfile* /tmp/

RUN cd /tmp && pipenv install --deploy --system

COPY docker_run.sh /app/run.sh
RUN chmod a+x /app/run.sh

COPY docker_config.json /media/config/config.json
COPY main.py /app/main.py
COPY app /app/app/
COPY converter/ /app/converter/
COPY misc/ /app/misc/

ENV FLASK_DEBUG 0
ENV CONVERTER_SESSION_TYPE "redis"
ENV CONVERTER_CONFIG_PATH "/media/config"
ENV BIND_ADDRESS 8000

EXPOSE 8000

WORKDIR /app/

CMD ["./run.sh"]