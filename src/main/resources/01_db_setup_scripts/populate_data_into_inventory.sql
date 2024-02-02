-- Insert data into the 'products' table
INSERT INTO products
VALUES (NULL, 'scooter', 'Small 2-wheel scooter', 3.14);
INSERT INTO products
VALUES (NULL, 'car battery', '12V car battery', 8.1);
INSERT INTO products
VALUES (NULL, '12-pack drill bits', '12-pack of drill bits with sizes ranging from #40 to #3', 0.8);
INSERT INTO products
VALUES (NULL, 'hammer', '12oz carpenter''s hammer', 0.75);
INSERT INTO products
VALUES (NULL, 'hammer', '14oz carpenter''s hammer', 0.875);
INSERT INTO products
VALUES (NULL, 'hammer', '16oz carpenter''s hammer', 1.0);
INSERT INTO products
VALUES (NULL, 'rocks', 'box of assorted rocks', 5.3);
INSERT INTO products
VALUES (NULL, 'jacket', 'water-resistant black windbreaker', 0.1);
INSERT INTO products
VALUES (NULL, 'spare tire', '24-inch spare tire', 22.2);

-- Insert data into the 'products_on_hand' table
INSERT INTO products_on_hand
VALUES (101, 3);
INSERT INTO products_on_hand
VALUES (102, 8);
INSERT INTO products_on_hand
VALUES (103, 18);
INSERT INTO products_on_hand
VALUES (104, 4);
INSERT INTO products_on_hand
VALUES (105, 5);
INSERT INTO products_on_hand
VALUES (106, 0);
INSERT INTO products_on_hand
VALUES (107, 44);
INSERT INTO products_on_hand
VALUES (108, 2);
INSERT INTO products_on_hand
VALUES (109, 5);

-- Insert data into the 'customers' table
INSERT INTO customers
VALUES (NULL, 'Sally', 'Thomas', 'sally.thomas@acme.com');
INSERT INTO customers
VALUES (NULL, 'George', 'Bailey', 'gbailey@foobar.com');
INSERT INTO customers
VALUES (NULL, 'Edward', 'Walker', 'ed@walker.com');
INSERT INTO customers
VALUES (NULL, 'Anne', 'Kretchmar', 'annek@noanswer.org');

-- Insert data into the 'orders' table
INSERT INTO orders
VALUES (NULL, TO_DATE('16-JAN-2016', 'DD-MON-YYYY'), 1001, 1, 101);
INSERT INTO orders
VALUES (NULL, TO_DATE('17-JAN-2016', 'DD-MON-YYYY'), 1002, 2, 105);
INSERT INTO orders
VALUES (NULL, TO_DATE('19-FEB-2016', 'DD-MON-YYYY'), 1002, 2, 106);
INSERT INTO orders
VALUES (NULL, TO_DATE('21-FEB-2016', 'DD-MON-YYYY'), 1003, 1, 107);

-- Insert data into the 'suppliers' table
INSERT INTO suppliers
VALUES (NULL, 'ABC Electronics', 'John Supplier', 'john@abc.com');
INSERT INTO suppliers
VALUES (NULL, 'XYZ Components', 'Jane Supplier', 'jane@xyz.com');

-- Insert data into the 'shipments' table
INSERT INTO shipments
VALUES (NULL, TO_DATE('10-FEB-2024', 'DD-MON-YYYY'), 1, 101, 20);
INSERT
INTO shipments
VALUES (NULL, TO_DATE('15-FEB-2024', 'DD-MON-YYYY'), 10002, 102, 30);


-- Insert data into the 'product_categories' table
INSERT INTO product_categories
VALUES (NULL, 'Electronics');
INSERT INTO product_categories
VALUES (NULL, 'Tools');
INSERT INTO product_categories
VALUES (NULL, 'Clothing');

-- Insert data into the 'product_category_mapping' table
INSERT INTO product_category_mapping
VALUES (101, 1);
INSERT INTO product_category_mapping
VALUES (102, 30002);
INSERT INTO product_category_mapping
VALUES (103, 30002);
INSERT INTO product_category_mapping
VALUES (104, 30002);
INSERT INTO product_category_mapping
VALUES (105, 30002);
INSERT INTO product_category_mapping
VALUES (106, 30002);
INSERT INTO product_category_mapping
VALUES (107, 30002);
INSERT INTO product_category_mapping
VALUES (108, 30003);
INSERT INTO product_category_mapping
VALUES (109, 30002);
-- Insert data into the 'product_reviews' table
INSERT INTO product_reviews
VALUES (NULL, 101, 'Great product!', 5, 'HappyCustomer');
INSERT INTO product_reviews
VALUES (NULL, 102, 'Works well for my projects.', 4, 'DIYEnthusiast');
INSERT INTO product_reviews
VALUES (NULL, 103, 'Average quality.', 3, 'MehReviewer');
INSERT INTO product_reviews
VALUES (NULL, 104, 'Excellent build!', 5, 'Craftsman');