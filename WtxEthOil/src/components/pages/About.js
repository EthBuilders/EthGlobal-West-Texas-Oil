import React from 'react';

const About = () => {
  return (
    <div className='container'>
      <div className='py-4'>
        <h1>About Page</h1>
        <p className='lead'>
        Description: Solving crude oil theft by reconciling Bill of Lading between mid-stream suppliers and end-stream refiners from Midland, Texas to Houston, Texas. We are using a specific test case here for a proof-of-concept. This could be a solution to putting oil and other transportable commodities on the blockchain which extends utility beyond theft prevention.
        </p>
        <p className='lead'>
        How we solve this issue is by taking the industry-standard BOL(Bill of Lading) and turning it into a unique NFT that goes through state transitions. Currently, there is a significant amount of theft in the industry which costs millions in loss. This happens most frequently in the transportation phase. What this solution seeks to do is hold parties accountable for the specific amount of oil at the time of transfer. When the BOL is transfered so does accountability of the product.
        </p>
        <p className='lead'>
        The application also provides tracking and all meta-data associated with the transportation and delivery of the product. This can be rolled into meaningful dashboards for the supplier, owner/operator, or fleet business. Employees could be paid in Aave which would accumulate interest while they worked and also release funds three weeks earlier than industry standard.
        </p>
        <p className='lead'>
        The Team: EthGlobal Market Make Hackathon team is a multinational group of individuals who are passionate about blockchain technologies and solving real-world problems.
        </p>
      </div>
    </div>
  );
};

export default About;
