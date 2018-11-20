# как запускать
# sudo docker-compose --project-name py-db -f docker-compose.yml up --build -d
# sudo docker-compose --project-name py-db -f docker-compose.yml run --rm python-db
# прогрузить данные командой 
# sh /home/load_data.sh
# запускаем базу
# psql --host $APP_POSTGRES_HOST -U postgres

#предварительно можно удалить все контейнеры
#sudo docker stop $(sudo docker ps -a -q)
#sudo docker rm $(sudo docker ps -a -q)
#sudo docker network prune


FROM continuumio/miniconda3

ENTRYPOINT ["/bin/bash"]

RUN apt-get update && apt-get install -y  postgresql-client curl nano mongodb mongo-tools

# Добавляем пакеты в анаконду - например, pandas
RUN conda install -c anaconda scipy numpy pandas sqlalchemy pymongo psycopg2 msgpack-numpy lz4 msgpack-python matplotlib seaborn statsmodels scikit-learn py-xgboost

# Копируем в контейнер скрипт для создания таблиц
COPY ./src/* /home/

