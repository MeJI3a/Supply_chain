USE supply_chain_db;

-- 1. Identifying Regions with High Late Delivery Risk
-- This query identifies countries and cities with the highest number of late deliveries.
-- It helps pinpoint geographic areas where supply chain issues are most frequent.
-- By focusing on locations with the highest 'Late_delivery_risk', businesses can prioritize these areas for optimization.

SELECT 
    Order_Country,  -- Country where the order was placed
    Order_City,     -- City where the order was placed
    COUNT(*) AS Late_Deliveries  -- Count of orders with delivery issues
FROM 
    orders
WHERE 
    Late_delivery_risk = 1  -- Filter only orders with late delivery risk
GROUP BY 
    Order_Country,  -- Grouping by country for regional analysis
    Order_City      -- Grouping by city for more detailed insights
ORDER BY 
    Late_Deliveries DESC limit 5;  -- Sorting by the number of late deliveries in descending order


-- 2. Identifying Products with the Lowest Profit Margins
-- This query identifies products that have the lowest profit margins.
-- Understanding these products helps businesses focus on renegotiating supplier contracts
-- or reviewing pricing strategies to improve profitability.

SELECT 
    p.Product_Name,  -- Name of the product
    p.Product_Category_Id,  -- Product category for classification
    AVG(oi.Order_Item_Profit_Ratio) AS Avg_Profit_Margin  -- Calculating average profit margin per product
FROM 
    order_items oi
JOIN 
    products p ON oi.Product_Card_Id = p.Product_Card_Id  -- Joining to retrieve product details
GROUP BY 
    p.Product_Name,  -- Grouping by product name for specific insights
    p.Product_Category_Id  -- Grouping by category for better segmentation
ORDER BY 
    Avg_Profit_Margin ASC  -- Sorting by the lowest profit margin
LIMIT 5;  -- Limiting to the top 5 products with the lowest profit margin


-- 3. Identifying Regions with the Highest Late Delivery Risk
-- This query identifies regions with the highest late delivery risk.
-- Understanding this helps to investigate supply chain inefficiencies in specific regions 
-- and optimize delivery processes.

SELECT 
    Order_Region,  -- Region where the orders are delivered
    COUNT(*) AS Late_Deliveries  -- Count of late deliveries in the region
FROM 
    orders
WHERE 
    Late_delivery_risk = 1  -- Focusing only on late deliveries
GROUP BY 
    Order_Region  -- Grouping results by region
ORDER BY 
    Late_Deliveries DESC  -- Sorting by the highest number of late deliveries
LIMIT 5;  -- Limiting the output to the top 5 regions with the highest late delivery risk


-- 4. Identifying the Most Profitable Product Categories
-- This query calculates the average profit margin for each product category.
-- This helps identify which product categories contribute the most to profitability.

SELECT 
    p.Product_Category_Id,  -- ID of the product category
    AVG(oi.Order_Item_Profit_Ratio) AS Avg_Profit_Margin  -- Average profit margin for the category
FROM 
    order_items oi
JOIN 
    products p ON oi.Product_Card_Id = p.Product_Card_Id  -- Joining products and order_items tables
GROUP BY 
    p.Product_Category_Id  -- Grouping by product category
ORDER BY 
    Avg_Profit_Margin DESC  -- Sorting categories by the highest average profit margin
LIMIT 5;  -- Limiting the output to the top 5 most profitable categories


-- 5. Delivery Performance Analysis
-- Step 1: Calculate average delivery delay for each shipping mode.
-- Step 2: Identify the shipping mode with the highest and lowest delay.
-- This is critical for identifying inefficiencies in the supply chain.

SELECT 
    s.Shipping_Mode,
    AVG(s.Days_for_shipping_real - s.Days_for_shipment_scheduled) AS Avg_Delivery_Delay
FROM 
    shipping s
GROUP BY 
    s.Shipping_Mode
ORDER BY 
    Avg_Delivery_Delay DESC;


-- 6. Evaluating Warehouse Efficiency
SELECT 
    Order_Region,
    COUNT(*) AS Total_Orders,
    SUM(Late_delivery_risk) AS Late_Deliveries,
    ROUND(SUM(Late_delivery_risk) / COUNT(*) * 100, 2) AS Late_Delivery_Percentage
FROM 
    orders
GROUP BY 
    Order_Region
ORDER BY 
    Late_Delivery_Percentage DESC
LIMIT 5;


-- 7. High-Value Customers and Their Behavior Patterns
SELECT 
    c.Customer_Id,
    CONCAT(c.Customer_Fname, ' ', c.Customer_Lname) AS Customer_Name,
    SUM(oi.Sales) AS Total_Sales,
    COUNT(o.Order_Id) AS Total_Orders,
    AVG(oi.Sales) AS Avg_Order_Value
FROM 
    customers c
JOIN 
    orders o ON c.Customer_Id = o.Customer_Id
JOIN 
    order_items oi ON o.Order_Id = oi.Order_Id
GROUP BY 
    c.Customer_Id, Customer_Name
ORDER BY 
    Total_Sales DESC
LIMIT 5;


-- 8. Monitoring Seasonal Demand Trends
SELECT 
    MONTH(order_date_DateOrders) AS Order_Month,
    SUM(oi.Sales) AS Total_Sales,
    COUNT(oi.Order_Item_Id) AS Total_Orders,
    pc.Product_Category_Id,
    pc.Product_Name
FROM 
    orders o
JOIN 
    order_items oi ON o.Order_Id = oi.Order_Id
JOIN 
    products pc ON oi.Product_Card_Id = pc.Product_Card_Id
GROUP BY 
    Order_Month, pc.Product_Category_Id, pc.Product_Name
ORDER BY 
    Total_Sales DESC
LIMIT 10;
