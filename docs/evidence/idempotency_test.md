a = fetch_all_pages("products")
b = save_raw_rows(a,"products")
df = normalize(pd.DataFrame(a))
c = upsert_dataframe('products',df)

232413\orders.json
2026-10-12 23:25:21,367 | INFO | pipeline | resource=products page=1 rows=50
2026-10-12 23:25:21,373 | INFO | pipeline | Saved RAW data: D:\AI_Native_DE_Module1_Student_Pack_v3_Speaker_Notes\AI_Native_DE_Module1_Student_Pack_v3_Speaker_Notes\data\raw\20261012_232521\products.json
2026-10-12 23:31:25,726 | INFO | pipeline | resource=products page=1 rows=50
2026-10-12 23:31:25,730 | INFO | pipeline | Saved RAW data: D:\AI_Native_DE_Module1_Student_Pack_v3_Speaker_Notes\AI_Native_DE_Module1_Student_Pack_v3_Speaker_Notes\data\raw\20261012_233125\products.json
2026-10-12 23:37:58,544 | INFO | pipeline | resource=products page=1 rows=50
2026-10-12 23:37:58,546 | INFO | pipeline | Saved RAW data: D:\AI_Native_DE_Module1_Student_Pack_v3_Speaker_Notes\AI_Native_DE_Module1_Student_Pack_v3_Speaker_Notes\data\raw\20261012_233758\products.json
2026-10-12 23:39:38,826 | INFO | pipeline | resource=products page=1 rows=50
2026-10-12 23:39:38,827 | INFO | pipeline | Saved RAW data: D:\AI_Native_DE_Module1_Student_Pack_v3_Speaker_Notes\AI_Native_DE_Module1_Student_Pack_v3_Speaker_Notes\data\raw\20261012_233938\products.json

2026-10-12 23:39:38,826 | INFO | pipeline | resource=products page=1 rows=50
2026-10-12 23:39:38,827 | INFO | pipeline | Saved RAW data: D:\AI_Native_DE_Module1_Student_Pack_v3_Speaker_Notes\AI_Native_DE_Module1_Student_Pack_v3_Speaker_Notes\data\raw\20261012_233938\products.json
Đang upsert bảng: products
Tổng số bản ghi trong bảng products: 520