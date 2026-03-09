# 📊 Toy_sales_perfomance_analysis

# 📌 Business Objectives

Welcome to my Power BI Portfolio repository!! 🚀

This repository is to analyze the Toy sales performance in one company. It identify the top-performing products and category, revenue and margin trends over time and distributors segments in order to support data-driven decisions for improving sales strategy and increasing overall revenue.

**Key Questions Addressed**:

1. The trend of revenue and profit over time?

2. Distributors and Products segmentation

3. The factors that impact the sales volume
---
# 🗂️ Dataset understanding

This dataset contains 4 tables:

1. The `Sales` table is a fact table. It contains information about sales, including the order date, id product, units sold, revenue discount and Cogs ratio.

  Each row represent the sales information in each order date

  The dataset contains approximately 10,000 transaction records collected over a 1-year period (2016).

2. The `Product` table is a dimension table. It contains information about each products, including id product, retail price, standard cost, category and distributors of each product .

  Each row represent the information of each product

  The dataset contains approximately 20 records.

3. The `Distributors` table is a dimension table. It contains information about each distributors, including ID com, company name, email, city and State of each company.

  Each row represent the information of each distributor

  The dataset contains approximately 6 records.

4. The `Categories` table is a dimension table. It contains information about categories, including Id category and category name.

  Each row represent the information of each category

  The dataset contains approximately 3 records.

---
# 🔗 Data Connection (Oracle → Power BI)
Power BI connects directly to the Oracle Database using the Oracle connector.

---
# 📈 Data Model
The Power BI data model is designed using a **star schema**, where:

  - sales_fact acts as the central fact table
  - Dimension tables provide descriptive attributes for analysis

Relationships are established using primary and foreign keys.

<img width="624" height="320" alt="data model" src="https://github.com/user-attachments/assets/1929ba6e-9f0a-479c-bb03-d8f82034abec" />

---
# 📊 Dashboard Features

The dashboard includes the following key visualizations:

- Revenue & profit trend over time

- Top-selling products

- Sales by region

- Distributors and products segmentation analysis

- KPI cards for total revenue, orders, and net margin

---
# 🛠 Tools Used

- Power BI
- Oracle Database (Oracle 19c)
- SQL
- Power Query
- DAX
---
# 👤 Author

I hope you find these resources informative and useful for your Power BI learning and application. Should you have any questions or feedback, feel free to reach out to me on LinkedIn. 🙌
