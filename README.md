# Boutique Purchase Requisition ( [click here for the backend](https://github.com/bienvenuushindi/btq-ms-front))

## Description

The Boutique Purchase Requisition project is a comprehensive solution designed to streamline and simplify the process of managing product requisitions for a small boutique. The primary goal is to alleviate the challenges faced by the person in charge of purchasing supplies by digitizing and automating various tasks associated with the traditional paper-based requisition process.


![Screenshot from 2024-05-04 03-39-12](https://github.com/bienvenuushindi/btq-ms-front/assets/26736582/dd2d1e19-ef1b-4608-b85b-9d23667c21f5)
![Screenshot from 2024-05-04 03-39-23](https://github.com/bienvenuushindi/btq-ms-front/assets/26736582/7587a168-0be0-4717-a564-ed23f0c4ef9d)
![Screenshot from 2024-05-04 03-39-47](https://github.com/bienvenuushindi/btq-ms-front/assets/26736582/36f847d9-4a45-4d7c-804a-2d5f88cf649a)
![Screenshot from 2024-05-04 03-39-55](https://github.com/bienvenuushindi/btq-ms-front/assets/26736582/fad4d7f0-7127-4619-8ed4-8b588a364974)
![Screenshot 2024-05-04 at 04-38-48 Create Next App](https://github.com/bienvenuushindi/btq-ms-front/assets/26736582/42fc50ea-56b1-488f-8042-f6ad7bd06308)
![Screenshot from 2024-05-04 03-40-00](https://github.com/bienvenuushindi/btq-ms-front/assets/26736582/ee1c2d93-3fa1-442d-84a3-60f02714bd33)
![Screenshot from 2024-05-04 03-40-07](https://github.com/bienvenuushindi/btq-ms-front/assets/26736582/7638c7e1-f03b-4f92-b821-7c0a804f385e)
![Screenshot from 2024-05-04 03-40-14](https://github.com/bienvenuushindi/btq-ms-front/assets/26736582/6ea30cc8-4908-4549-a4e1-f9108b963846)


## BTQ_MS High-Level Architecture Diagram

Both the Customer App (React Native and Web App) and the Management App (Next.js Frontend) communicate with a single Monolithic API, which is a Rails API serving both functionalities. The Monolithic API handles all requests from the client applications and contains all the business logic and functionalities. A shared database is still used for data storage, ensuring data consistency across the platform.

![Screenshot from 2024-05-04 03-55-07](https://github.com/bienvenuushindi/btq-ms-front/assets/26736582/c4e02936-bc9d-4b1b-80ff-1c7bcea2f900)



## Purpose and Challenges

In the traditional process, the person responsible for purchases encounters numerous challenges, including:

- **Supplier Knowledge and Price Estimation:** The individual must be familiar with different suppliers and have accurate price estimates for various products to determine the required budget.
  
- **Price Variation Management:** Fluctuating prices necessitate keeping track of price changes to ensure accurate cost estimations and updates at the store.
  
- **Inventory Updates and Shortages:** Awareness of product shortages and anticipated restock dates is essential for managing inventory effectively.
  
- **Human Error and Inconsistencies:** The paper-based system is prone to errors, leading to inconsistent purchasing decisions and inaccuracies.
  
- **Dependency on a Single Individual:** In case of absence of the person in charge, continuity of the process becomes challenging, as someone else must take over without sufficient knowledge.

## Project Objectives

The primary objective of the Boutique Purchase Requisition application is to address these challenges and offer a comprehensive solution to improve requisition management. The application aims to provide the following functionalities:

- **Requisition Management:** Users can create and update product requisitions digitally, eliminating the need for paper documents. This feature enhances accuracy and provides a clear overview of required items.
  
- **Product Management:** The application allows users to add, update, and manage product information. This ensures accurate product data and seamless integration with requisitions.
  
- **Supplier Management:** Users can maintain supplier information, including contact details and product offerings. This simplifies the process of selecting and reaching out to suppliers.

## Features

- Digitizes requisitions, streamlining the requisition creation and update process.
- Manages product information to ensure accuracy and integration with requisitions.
- Maintains supplier details, simplifying supplier selection and interaction.


## Contributing

We welcome contributions to the Boutique Purchase Requisition project. To contribute:

1. Fork the repository.
2. Create a new branch (`git checkout -b feature/new-feature`).
3. Make your changes.
4. Commit your changes (`git commit -am 'Add new feature'`).
5. Push to the branch (`git push origin feature/new-feature`).
6. Create a new Pull Request.

## License

This project is licensed under the [MIT License](LICENSE).
