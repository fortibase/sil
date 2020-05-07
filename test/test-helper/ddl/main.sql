/*
Created: 9/20/2019
Modified: 10/14/2019
Project: pg-structrue-test
Model: Main
Author: Özüm Eldoğan
Version: 1.0.0
Database: PostgreSQL 10
 */
CREATE SCHEMA extra_modules;

CREATE EXTENSION IF NOT EXISTS hstore SCHEMA extra_modules;

-- Create schemas section -------------------------------------------------
CREATE SCHEMA IF NOT EXISTS "other_schema";

CREATE SCHEMA IF NOT EXISTS "extra_modules";

-- Create functions section -------------------------------------------------
CREATE FUNCTION "public"."t_updated_at" ()
    RETURNS TRIGGER
    LANGUAGE plpgsql
    VOLATILE
    AS $$
BEGIN
  NEW.updated_at := now();
  RETURN NEW;
END;
$$;

-- Create user data types section -------------------------------------------------
CREATE TYPE "udt_range" AS RANGE (
  SUBTYPE = float8,
  SUBTYPE_DIFF = float8mi
);

CREATE TYPE "udt_enum" AS ENUM (
  'option',
  '"quote"',
  'with,comma and "quote"'
);

CREATE TYPE "other_schema"."udt_composite" AS (
  "o_field_1" Numeric,
  "o_field_2" udt_range[]
);

CREATE TYPE "udt_composite" AS (
  "field1" int4,
  "field2" Timestamp ( 0
)
  WITH time zone,
  "field3" udt_enum,
  "field4" other_schema.udt_composite[][]);

-- Create domain types section -------------------------------------------------
CREATE DOMAIN "cross_schema_domain" AS "udt_composite"[] NOT NULL;

CREATE DOMAIN "price" AS Numeric(8, 2)
DEFAULT 1.2 NOT NULL CHECK (VALUE > 0);

-- Create tables section -------------------------------------------------
-- Table public.type_table

CREATE TABLE "public"."type_table" ( "id" Serial NOT NULL, "default_empty_string" Text DEFAULT '', "field1_a" Character varying, "field1_b" Character varying(2), "field2_a" Numeric, "field2_b" Numeric(3, 2), "field3" Character (7), "field4_a" Timestamp, "field4_b" Timestamp(0), "field5" Bit(4), "field6" Bit varying(10), "field7_a" Timestamp WITH time zone, "field7_b" Timestamp(0) WITH time zone, "field8" Time(6), "field9" Time(4) WITH time zone, "field10" Smallint, "field11" Integer DEFAULT 1, "field12" Bigint, "field13" "other_schema"."udt_composite", "field14" "udt_composite", "field15" "udt_enum", "field16" "udt_range", "field17" Jsonb, "field18" "cross_schema_domain", "field19" "price", "a_field1" "udt_composite"[], "a_field2" Timestamp(1) WITH time zone[][]
)
WITH (
  autovacuum_enabled = TRUE
);

COMMENT ON TABLE "public"."type_table" IS 'Type Table Description. [pg-structure]{ jsonKey: "json value" }[/pg-structure]';

COMMENT ON COLUMN "public"."type_table"."id" IS 'id description. [pg-structure]{ columnData: 1 }[/pg-structure]';

COMMENT ON COLUMN "public"."type_table"."default_empty_string" IS '[pg-structure]false_json:b:c[/pg-structure]';

COMMENT ON COLUMN "public"."type_table"."field1_a" IS 'Comment without data.';

-- Add keys for table public.type_table
ALTER TABLE "public"."type_table"
  ADD CONSTRAINT "type_table_pk" PRIMARY KEY ("id");

-- Table public.cart
CREATE TABLE "public"."cart" ( "id" Serial NOT NULL, "created_at" Timestamp(0) DEFAULT now() NOT NULL, "updated_at" Timestamp(0) DEFAULT now() NOT NULL, "contact_id" Integer
)
WITH (
  autovacuum_enabled = TRUE
);

COMMENT ON TABLE "public"."cart" IS 'Alışveriş sepetlerini tutan tablo.';

-- Create indexes for table public.cart
CREATE INDEX "IX_contactcarts" ON "public"."cart" ("contact_id");

-- Add keys for table public.cart
ALTER TABLE "public"."cart"
  ADD CONSTRAINT "Key3" PRIMARY KEY ("id");

-- Create triggers for table public.cart
CREATE TRIGGER "updated_at"
  BEFORE UPDATE ON "public"."cart"
  FOR EACH ROW
  EXECUTE PROCEDURE "public"."t_updated_at" ();

-- Table public.cart_line_item
CREATE TABLE "public"."cart_line_item" ( "cart_id" Integer NOT NULL, "product_id" Integer NOT NULL, "alternative_product_id" Integer, "second_cart_id" Integer, "quantity" Smallint DEFAULT 1 NOT NULL
)
WITH (
  autovacuum_enabled = TRUE
);

COMMENT ON TABLE "public"."cart_line_item" IS 'Sepetteki ürünleri tutan tablo.';

-- Create indexes for table public.cart_line_item
CREATE INDEX "IX_cart_line_itemproduct" ON "public"."cart_line_item" ("alternative_product_id");

CREATE INDEX "IX_cart_line_itemcart" ON "public"."cart_line_item" ("second_cart_id");

-- Add keys for table public.cart_line_item
ALTER TABLE "public"."cart_line_item"
  ADD CONSTRAINT "Key5" PRIMARY KEY ("cart_id", "product_id");

-- Create triggers for table public.cart_line_item
CREATE TRIGGER "updated_at"
  BEFORE UPDATE ON "public"."cart_line_item"
  FOR EACH ROW
  EXECUTE PROCEDURE "public"."t_updated_at" ();

-- Table public.class
CREATE TABLE "public"."class" ( "name" Character varying(20) NOT NULL, "teacher_name" Character varying(20) NOT NULL, "teacher_surname" Character varying(20) NOT NULL, "is_popular" Boolean
)
WITH (
  autovacuum_enabled = TRUE
);

COMMENT ON TABLE "public"."class" IS '3''lü composite key test etmek için oluşturulmuş yapay ikinci tablo.';

COMMENT ON COLUMN "public"."class"."name" IS 'Ders ismi';

COMMENT ON COLUMN "public"."class"."teacher_name" IS 'Dersi veren hocanın ismi';

COMMENT ON COLUMN "public"."class"."teacher_surname" IS 'Dersi veren hocanın soy ismi';

COMMENT ON COLUMN "public"."class"."is_popular" IS 'Popüler ders mi?';

-- Add keys for table public.class
ALTER TABLE "public"."class"
  ADD CONSTRAINT "Key10" PRIMARY KEY ("name", "teacher_name", "teacher_surname");

-- Table public.class_registry
CREATE TABLE "public"."class_registry" ( "name" Character varying(20) NOT NULL, "teacher_name" Character varying(20) NOT NULL, "teacher_surname" Character varying(20) NOT NULL, "first_name" Character varying(20) NOT NULL, "middle_name" Character varying(20) NOT NULL, "last_name" Character varying(20) NOT NULL
)
WITH (
  autovacuum_enabled = TRUE
);

COMMENT ON TABLE "public"."class_registry" IS '3 lü komposit key ile birleşen many to many tabloları test etmek için yapay tablo.';

-- Add keys for table public.class_registry
ALTER TABLE "public"."class_registry"
  ADD CONSTRAINT "Key11" PRIMARY KEY ("name", "teacher_name", "teacher_surname", "first_name", "middle_name", "last_name");

-- Table public.message
CREATE TABLE "public"."message" ( "id" Serial NOT NULL, "sender_first_name" Character varying(20), "sender_middle_name" Character varying(20), "sender_last_name" Character varying(20), "receiver_first_name" Character varying(20), "receiver_middle_name" Character varying(20), "receiver_last_name" Character varying(20)
)
WITH (
  autovacuum_enabled = TRUE
);

COMMENT ON TABLE "public"."message" IS '3''lü composite key içeren self referencing tabloları test etmek için yapay tablo.';

COMMENT ON COLUMN "public"."message"."id" IS 'Kayıt no';

COMMENT ON COLUMN "public"."message"."sender_first_name" IS 'Gönderen ilk ismi';

COMMENT ON COLUMN "public"."message"."sender_middle_name" IS 'Gönderen orta ismi';

COMMENT ON COLUMN "public"."message"."sender_last_name" IS 'Gönderen soy ismi';

COMMENT ON COLUMN "public"."message"."receiver_first_name" IS 'Mesaj alanın ilk ismi';

COMMENT ON COLUMN "public"."message"."receiver_middle_name" IS 'Mesaj alanın orta ismi.';

COMMENT ON COLUMN "public"."message"."receiver_last_name" IS 'Mesaj alanın soy ismi.';

-- Create indexes for table public.message
CREATE INDEX "IX_Relationship11" ON "public"."message" ("sender_first_name", "sender_middle_name", "sender_last_name");

CREATE INDEX "IX_Relationship12" ON "public"."message" ("receiver_first_name", "receiver_middle_name", "receiver_last_name");

-- Add keys for table public.message
ALTER TABLE "public"."message"
  ADD CONSTRAINT "Key12" PRIMARY KEY ("id");

-- Table public.product
CREATE TABLE "public"."product" ( "id" Serial NOT NULL, "product_category_id" Integer, "name" Character varying(20) NOT NULL
)
WITH (
  autovacuum_enabled = TRUE
);

COMMENT ON TABLE "public"."product" IS 'Ürünleri tutan tablo.';

-- Create indexes for table public.product
CREATE INDEX "IX_product_categoryproducts" ON "public"."product" ("product_category_id");

-- Add keys for table public.product
ALTER TABLE "public"."product"
  ADD CONSTRAINT "Key4" PRIMARY KEY ("id");

-- Create triggers for table public.product
CREATE TRIGGER "updated_at"
  BEFORE UPDATE ON "public"."product"
  FOR EACH ROW
  EXECUTE PROCEDURE "public"."t_updated_at" ();

-- Table public.product_category
CREATE TABLE "public"."product_category" ( "id" Serial NOT NULL, "parent_category_id" Integer, "name" Character varying(20) NOT NULL
)
WITH (
  autovacuum_enabled = TRUE
);

COMMENT ON TABLE "public"."product_category" IS 'Ürün kategorilerini tutan tablo.';

COMMENT ON COLUMN "public"."product_category"."id" IS 'Kayıt no.';

COMMENT ON COLUMN "public"."product_category"."name" IS 'Ürün kategori ismi.';

-- Create indexes for table public.product_category
CREATE INDEX "IX_product_categoryproduct_categorys" ON "public"."product_category" ("parent_category_id");

-- Add keys for table public.product_category
ALTER TABLE "public"."product_category"
  ADD CONSTRAINT "Key6" PRIMARY KEY ("id");

-- Table public.student
CREATE TABLE "public"."student" ( "first_name" Character varying(20) NOT NULL, "middle_name" Character varying(20) NOT NULL, "last_name" Character varying(20) NOT NULL, "class" Smallint
)
WITH (
  autovacuum_enabled = TRUE
);

COMMENT ON TABLE "public"."student" IS '3''lü composit key test için oluşturulmuş yapay tablo.';

COMMENT ON COLUMN "public"."student"."first_name" IS 'Adı.';

COMMENT ON COLUMN "public"."student"."middle_name" IS 'Orta ismi';

COMMENT ON COLUMN "public"."student"."last_name" IS 'Soy ismi';

-- Add keys for table public.student
ALTER TABLE "public"."student"
  ADD CONSTRAINT "Key9" PRIMARY KEY ("first_name", "middle_name", "last_name");

-- Table account
CREATE TABLE "account" (
  "id" Serial NOT NULL,
  "created_at" Timestamp(0) DEFAULT now() NOT NULL,
  "updated_at" Timestamp(0) DEFAULT now() NOT NULL,
  "name" Character varying(20) DEFAULT 'no_name' NOT NULL,
  "c" Circle,
  CONSTRAINT "account_update_later" CHECK (created_at <= updated_at)
)
WITH (
  autovacuum_enabled = TRUE
);

-- Create indexes for table account
CREATE INDEX "ix_expression" ON "account" (LOWER(name));

CREATE INDEX "ix_column_and_expression" ON "account" (id, LOWER(name));

CREATE INDEX "ix_columns" ON "account" ("id", "name");

CREATE UNIQUE INDEX "ix_partial_unique" ON "account" ("id")
WHERE
  id > 99;

ALTER TABLE "account"
  ADD CONSTRAINT "ix_exclude"
  EXCLUDE USING gist (c WITH &&);

-- Add keys for table account
ALTER TABLE "account"
  ADD CONSTRAINT "KeyEntity11" PRIMARY KEY ("id");

ALTER TABLE "account"
  ADD CONSTRAINT "account_unique_constraint" UNIQUE ("name", "created_at");

-- Create triggers for table account
CREATE TRIGGER "account_updated_at"
  BEFORE UPDATE ON "account"
  FOR EACH ROW
  EXECUTE PROCEDURE "public"."t_updated_at" ();

-- Table other_schema.cart
CREATE TABLE "other_schema"."cart" ( "id" Serial NOT NULL, "contact_id" Integer, "some_data" Bigint
)
WITH (
  autovacuum_enabled = TRUE
);

-- Create indexes for table other_schema.cart
CREATE INDEX "IX_contactcarts" ON "other_schema"."cart" ("contact_id");

-- Add keys for table other_schema.cart
ALTER TABLE "other_schema"."cart"
  ADD CONSTRAINT "Keycart1" PRIMARY KEY ("id");

-- Table contact
CREATE TABLE "contact" (
  "id" Serial NOT NULL,
  "primary_account_id" Integer,
  "secondary_account_id" Integer
)
WITH (
  autovacuum_enabled = TRUE
);

-- Create indexes for table contact
CREATE INDEX "IX_account_primary_contacts" ON "contact" ("primary_account_id");

CREATE INDEX "IX_account_secondary_contacts" ON "contact" ("secondary_account_id");

-- Add keys for table contact
ALTER TABLE "contact"
  ADD CONSTRAINT "Keycontact1" PRIMARY KEY ("id");

-- Table Part
CREATE TABLE "Part" (
  "id" Serial NOT NULL,
  "groupId" Integer,
  "alternativeGroupId" Integer
)
WITH (
  autovacuum_enabled = TRUE
);

-- Add keys for table Part
ALTER TABLE "Part"
  ADD CONSTRAINT "KeyPart1" PRIMARY KEY ("id");

-- Table cancelled_item
CREATE TABLE "cancelled_item" (
  "cart_id" Integer NOT NULL,
  "product_id" Integer NOT NULL
)
WITH (
  autovacuum_enabled = TRUE
);

-- Add keys for table cancelled_item
ALTER TABLE "cancelled_item"
  ADD CONSTRAINT "Keycancelled_item1" PRIMARY KEY ("cart_id", "product_id");

-- Table PartGroup
CREATE TABLE "PartGroup" (
  "id" Serial NOT NULL
)
WITH (
  autovacuum_enabled = TRUE
);

-- Add keys for table PartGroup
ALTER TABLE "PartGroup"
  ADD CONSTRAINT "KeyCamelCaseGroup1" PRIMARY KEY ("id");

-- Create views section -------------------------------------------------
CREATE VIEW "v_account_primary_contact" AS
SELECT
  "account"."id" AS "account_id",
  "contact"."id" AS "contact_id",
  account.id + contact.id AS "sum_of_id"
FROM
  "account",
  "contact"
WHERE
  account.id = contact.primary_account_id;

-- Create materialized query tables section -------------------------------------------------
CREATE MATERIALIZED VIEW "mv_contact_other_schema_cart" WITH ( autovacuum_enabled = TRUE
) AS
SELECT
  cart.id AS cart_id,
  contact.id AS contact_id
FROM
  other_schema.cart
  INNER JOIN public.contact ON public.contact.id = other_schema.cart.contact_id;

-- Create foreign keys (relationships) section -------------------------------------------------
ALTER TABLE "public"."cart_line_item"
  ADD CONSTRAINT "cart_line_item_first_cart" FOREIGN KEY ("cart_id") REFERENCES "public"."cart" ("id") ON DELETE RESTRICT ON
  UPDATE
    CASCADE;

COMMENT ON CONSTRAINT "cart_line_item_first_cart" ON "public"."cart_line_item" IS '[pg-structure]
{
    name: {
        o2m: ''json_cart_line_items'',
        m2o: ''json_cart''
    }
}
[/pg-structure]';

ALTER TABLE "public"."cart_line_item"
  ADD CONSTRAINT "cart_line_item_primary_product" FOREIGN KEY ("product_id") REFERENCES "public"."product" ("id") ON DELETE RESTRICT ON
  UPDATE
    CASCADE;

ALTER TABLE "public"."product"
  ADD CONSTRAINT "main_product_primary_product_category" FOREIGN KEY ("product_category_id") REFERENCES "public"."product_category" ("id") ON DELETE CASCADE ON
  UPDATE
    CASCADE;

ALTER TABLE "public"."product_category"
  ADD CONSTRAINT "product_category_parent" FOREIGN KEY ("parent_category_id") REFERENCES "public"."product_category" ("id") ON DELETE CASCADE ON
  UPDATE
    CASCADE;

ALTER TABLE "contact"
  ADD CONSTRAINT "contact_primary_account" FOREIGN KEY ("primary_account_id") REFERENCES "account" ("id") ON DELETE CASCADE ON
  UPDATE
    CASCADE;

ALTER TABLE "contact"
  ADD CONSTRAINT "contact_secondary_account" FOREIGN KEY ("secondary_account_id") REFERENCES "account" ("id") ON DELETE CASCADE ON
  UPDATE
    CASCADE;

ALTER TABLE "other_schema"."cart"
  ADD CONSTRAINT "other_cart_contact" FOREIGN KEY ("contact_id") REFERENCES "contact" ("id") ON DELETE CASCADE ON
  UPDATE
    CASCADE;

ALTER TABLE "public"."cart"
  ADD CONSTRAINT "cart_contact" FOREIGN KEY ("contact_id") REFERENCES "contact" ("id") ON DELETE CASCADE ON
  UPDATE
    CASCADE;

ALTER TABLE "public"."message"
  ADD CONSTRAINT "message_sender_student" FOREIGN KEY ("sender_first_name", "sender_middle_name", "sender_last_name") REFERENCES "public"."student" ("first_name", "middle_name", "last_name") ON DELETE CASCADE ON
  UPDATE
    CASCADE;

ALTER TABLE "public"."message"
  ADD CONSTRAINT "message_receiver_student" FOREIGN KEY ("receiver_first_name", "receiver_middle_name", "receiver_last_name") REFERENCES "public"."student" ("first_name", "middle_name", "last_name") ON DELETE CASCADE ON
  UPDATE
    CASCADE;

COMMENT ON CONSTRAINT "message_receiver_student" ON "public"."message" IS '[pg-structure]
{
    name: {
        m2m: ''message_sent''
    }
}
[/pg-structure]';

ALTER TABLE "public"."class_registry"
  ADD CONSTRAINT "class_registry_class" FOREIGN KEY ("name", "teacher_name", "teacher_surname") REFERENCES "public"."class" ("name", "teacher_name", "teacher_surname") ON DELETE RESTRICT ON
  UPDATE
    CASCADE;

ALTER TABLE "public"."class_registry"
  ADD CONSTRAINT "class_registry_student" FOREIGN KEY ("first_name", "middle_name", "last_name") REFERENCES "public"."student" ("first_name", "middle_name", "last_name") ON DELETE RESTRICT ON
  UPDATE
    CASCADE;

ALTER TABLE "public"."cart_line_item"
  ADD CONSTRAINT "cart_line_item_alternative_product" FOREIGN KEY ("alternative_product_id") REFERENCES "public"."product" ("id") ON DELETE CASCADE ON
  UPDATE
    CASCADE;

ALTER TABLE "public"."cart_line_item"
  ADD CONSTRAINT "cart_line_item_second_cart" FOREIGN KEY ("second_cart_id") REFERENCES "public"."cart" ("id") ON DELETE CASCADE ON
  UPDATE
    CASCADE;

ALTER TABLE "cancelled_item"
  ADD CONSTRAINT "cancelled_item_first_cart" FOREIGN KEY ("cart_id") REFERENCES "public"."cart" ("id") ON DELETE CASCADE ON
  UPDATE
    CASCADE;

ALTER TABLE "cancelled_item"
  ADD CONSTRAINT "cancelled_item_product" FOREIGN KEY ("product_id") REFERENCES "public"."product" ("id") ON DELETE CASCADE ON
  UPDATE
    CASCADE;

ALTER TABLE "Part"
  ADD CONSTRAINT "PartPartGroup" FOREIGN KEY ("groupId") REFERENCES "PartGroup" ("id") ON DELETE CASCADE ON
  UPDATE
    CASCADE;

ALTER TABLE "Part"
  ADD CONSTRAINT "Stock,Alternative" FOREIGN KEY ("alternativeGroupId") REFERENCES "PartGroup" ("id") ON DELETE CASCADE ON
  UPDATE
    CASCADE;

