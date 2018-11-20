#/bin/sh


psql --host $APP_POSTGRES_HOST  -U postgres -c \
    "DROP TABLE IF EXISTS sales"
psql --host $APP_POSTGRES_HOST  -U postgres -c \
    "DROP TABLE IF EXISTS items"
psql --host $APP_POSTGRES_HOST  -U postgres -c \
    "DROP TABLE IF EXISTS retail_offices"
psql --host $APP_POSTGRES_HOST  -U postgres -c \
    "DROP TABLE IF EXISTS shops"
psql --host $APP_POSTGRES_HOST  -U postgres -c \
    "DROP TABLE IF EXISTS discount"


echo "Загружаем sales.csv..."
psql --host $APP_POSTGRES_HOST -U postgres -c '
 CREATE TABLE "sales" (
	"OPER_DATE" TIMESTAMP NOT NULL,
	"CODE_OFFICE" TEXT NULL,
	"TP" varchar NULL,
	"DOC_NUMBER" bigint NOT NULL,
	"ITEM_ARTICLE" TEXT NOT NULL,
	"QTY" bigint NOT NULL,
	"AMOUNT_AUTO_DISCOUNT" money NULL,
	"AMOUNT_RUR" money NULL,
	"PAYMENT_FORM" TEXT NULL,
	"KEY_DISCOUNT" int NULL
	--,CONSTRAINT sales_pk PRIMARY KEY ("OPER_DATE","DOC_NUMBER", "ITEM_ARTICLE")
) WITH (
  OIDS=FALSE
); 
'

psql --host $APP_POSTGRES_HOST  -U postgres -c \
    "\\copy sales FROM '/data/sales.csv' DELIMITER ';' CSV HEADER"

echo "Загружаем items.csv..."
psql --host $APP_POSTGRES_HOST -U postgres -c '
CREATE TABLE "items" (
	"ITEM_ARTICLE" TEXT NOT NULL,
	"ITEM_NAME" TEXT NULL,
	"ITEM_CATEGORY" TEXT NULL,
	"ITEM_SUBCATEGORY" TEXT NULL,
	"ITEM_MARK" TEXT NULL,
	"VIEW_ITEM" TEXT NULL,
	"MOD_NO_COLOR" TEXT NULL
	--,CONSTRAINT items_pk PRIMARY KEY ("ITEM_ARTICLE")
) WITH (
  OIDS=FALSE
);
'

psql --host $APP_POSTGRES_HOST -U postgres -c \
    "\\copy items FROM '/data/items.csv' DELIMITER ';' CSV HEADER"

echo "Загружаем shops.csv..."
psql --host $APP_POSTGRES_HOST -U postgres -c '
CREATE TABLE "shops" (
	"MARKET_CODE" TEXT NULL,
	"SHOP" TEXT  NULL,
	"CODE_POINTS_SALE" TEXT NULL,
	"CODE_OFFICE" TEXT NOT NULL,
	"SHEDULE_NAME" TEXT  NULL,
	"TIME_ZONE" TEXT NULL
	--,CONSTRAINT shops_pk PRIMARY KEY ("CODE_OFFICE")
) WITH (
  OIDS=FALSE
);
'

psql --host $APP_POSTGRES_HOST -U postgres -c \
    "\\copy shops FROM '/data/shops.csv' DELIMITER ';' CSV HEADER"


echo "Загружаем retail_offices.csv..."
psql --host $APP_POSTGRES_HOST -U postgres -c '
CREATE TABLE "retail_offices" (
	"YM" TEXT NOT NULL,
	"OFFICE_ID" TEXT NOT NULL,
	"REGION" TEXT NULL,
	"BRANCHNAME" TEXT NULL,
	"BRANCH_ADDR" TEXT NULL,
	"STATUS" TEXT NULL
	--,CONSTRAINT retail_offices_pk PRIMARY KEY ("YM","OFFICE_ID")
) 
WITH (
  OIDS=FALSE
);
'

psql --host $APP_POSTGRES_HOST -U postgres -c \
    "\\copy retail_offices FROM '/data/retail_offices.csv' DELIMITER ';' CSV HEADER"


echo "Загружаем discount.csv..."
psql --host $APP_POSTGRES_HOST -U postgres -c '
CREATE TABLE "discount" (
	"DISCOUNT_NAME" TEXT NULL,
	"AMOUNT_DISCOUNT" money NULL,
	"OPER_DATE" TIMESTAMP NOT NULL,
	"DOC_NUMBER" bigint NOT NULL,
	"KEY_DISCOUNT" int NULL
) WITH (
  OIDS=FALSE
);

'

psql --host $APP_POSTGRES_HOST -U postgres -c \
    "\\copy discount FROM '/data/discount.csv' DELIMITER ';' CSV HEADER"


# используем Postgres для препроцессинга


# выгружаем данные с другим сепаратором
#psql --host $APP_POSTGRES_HOST -U postgres -c \
#    "\\copy (select * from keywords) to '/data/keywords.tsv' with delimiter as E'\t'"
