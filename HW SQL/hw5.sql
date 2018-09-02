-- Копируем файл с тегами в MongoDB

/usr/bin/mongoimport --host $APP_MONGO_HOST --port $APP_MONGO_PORT --db 
movies --collection tags --file /data/simple_tags.json


--подсчет количества тегов 

db.tags.aggregate([{$count: "name"}])

-- подсчет количества фильмов с тегом "woman"

db.tags.aggregate( 
    {$match: {name: "woman"}},
    {$group: {_id: "$name", number: {$sum: 1}}}  
)


-- вывести топ-3 самых распространенных тегов


db.tags.aggregate( 
     [
     {$group: {_id: "$name", number: {$sum: 1}}}, 
     {$sort: {number: -1}},
     { $limit : 3 }
     ]
)

