def test_clean_sales(spark_session):
    from bluebrick.transformations import clean_sales

    src = spark_session.createDataFrame(
        [(1, " A ", None, 10.0), (0, "bad", "2024-01-01", 1.0), (2, "B", "2024-01-02", None)],
        "id INT, name STRING, tx_date STRING, amount DOUBLE",
    )

    res = clean_sales(src)

    # Expect only valid rows (id > 0 and amount not null)
    assert res.count() == 1

    # Name trimmed and uppercased; tx_date cast to date
    row = res.collect()[0]
    assert row[1] == "A"  # name
    assert str(row[2]) == "None" or str(row[2]) == "null" or row[2] is None  # date can be None
    assert isinstance(row[3], float)
