## Data Dimenstion Modeling
- attributes of entity such as users ID, birthdate, address, etc.

## Types of Data Models
- OLTP - Online Transaction Processing. Minimize data duplication, primary keys, and foreign keys, optimization process, low volume of data processing, lot of join etc. Lookup single row/entity.
- OLAP - Online Analytical Processing. Minimize JOINs, Optimize for large volume of data processing, GROUP BY queries, etc. Lookup whole dataset.
- Master data table. Optimize for completeness of entity definition, deduped. [Middle layer] [OLAP] [OLTP]

## 4-layer data modeling continuum
=> Production Database Snapshots [Eg, Airbnb: prices, post, transactional data etc] -> Master Data Table [Merge those snapshots into one master table]
=> Master Data Table -> OLAP Cubes [Flatten the data table, multiple rows per entity, group by (age, gender, location, etc), etc.]
=> OLAP -> Metrics [aggregate data, calculate metrics (like average price, distill the data), etc.]

## Cumulative Table Design
- Core components: Holding all the data that ever existed. Holding on the history. It has 2 dataframes or table (todays and yesterdays) and then FULL OUTER JOIN the two data frames together (merge to get whole set), then COALESCE as if they match or not.
- Use case: Use it to get the whole history of a user. Say growth analysis- we see dimenstion of users over time. or state transition tracking of growth of users over time (churn analysis/retention/ressurected).