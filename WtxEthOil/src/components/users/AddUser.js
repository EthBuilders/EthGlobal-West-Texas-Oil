import React, { useState, useEffect } from 'react';
import { useHistory } from 'react-router-dom';
import InputField from "../layout/Input";
import Web3 from 'web3';
const tokenAbi = require('../../token.json');
const bolAbi = require("../../bol.json");

const AddUser = () => {
  let history = useHistory();
  let [bol, setBol] = useState({ address: "0x0000000000000000000000000000000000000000", tokenContract: "0x0000000000000000000000000000000000000000" });
  const [user, setUser] = useState({
    driver: '',
    serialNumber: '',
    latitudeOriginDegrees: '',
    latitudeOriginMinutes: '',
    latitudeOriginSeconds: '',
    latitudeOriginCardinalDirection: '',
    longitudeOriginDegrees: '',
    longitudeOriginMinutes: '',
    longitudeOriginSeconds: '',
    longitudeOriginCardinalDirection: '',
    latitudeDestinationDegrees: '',
    latitudeDestinationMinutes: '',
    latitudeDestinationSeconds: '',
    latitudeDestinationCardinalDirection: '',
    longitudeDestinationDegrees: '',
    longitudeDestinationMinutes: '',
    longitudeDestinationSeconds: '',
    longitudeDestinationCardinalDirection: '',
    quantity: '',
  });
  let account;

  useEffect(() => {
    loadWeb3();
  })

  function cleanData(data) {
    let result = {}
    let pat = /^(latitude|longitude).*/;
    for (const [key, value] of Object.entries(data)) {
      if (pat.test(key)) {
        result[key] = parseInt(value);
      } else {
        result[key] = value;
      }
    }
    return [
      result.driver,
      result.serialNumber,
      [
        [
          result.latitudeOriginDegrees,
          result.latitudeOriginMinutes,
          result.latitudeOriginSeconds,
          result.latitudeOriginCardinalDirection,
        ],
        [
          result.longitudeOriginDegrees,
          result.longitudeOriginMinutes,
          result.longitudeOriginSeconds,
          result.longitudeOriginCardinalDirection,

        ]
      ],
      [
        [
          result.latitudeDestinationDegrees,
          result.latitudeDestinationMinutes,
          result.latitudeDestinationSeconds,
          result.latitudeDestinationCardinalDirection,
        ],
        [
          result.longitudeDestinationDegrees,
          result.longitudeDestinationMinutes,
          result.longitudeDestinationSeconds,
          result.longitudeDestinationCardinalDirection,

        ]
      ],
      result.quantity
    ];
  }


  const loadWeb3 = async () => {
    if (window.ethereum) {
      window.web3 = new Web3(window.ethereum)
      await window.ethereum.enable()
    }
    else if (window.web3) {
      window.web3 = new Web3(window.web3.currentProvider)
    }
    else {
      window.alert('Non-Ethereum browser detected. You should consider trying MetaMask!')
    }
  }

  // const { driver, serialNumber, origin, destination, quantity } = user;
  const onInputChange = (e) => {
    setUser({ ...user, [e.target.name]: e.target.value });
  };

  const onSubmit = async (e) => {
    e.preventDefault();
    let data = cleanData(user);

    window.web3.currentProvider.enable();
    let web3 = new Web3(window.web3.currentProvider);

    web3.eth.getAccounts().then((e) => {
      account = e[0];
      console.log(`The account is ${account}`);
      let bolContract = new web3.eth.Contract(bolAbi.abi, bol.address, { from: account });

      console.log(bolContract.defaultAccount);

      bolContract.methods.createBillOfLading(data, bol.tokenContract, 100).send();

    })



    // history.push('/');
  };

  return (
    <div>
      <div className='container'>
        <div className='w-75 mx-auto shadow p-5'>
          <h2 className='text-center mb-4'>BOL Contract Address</h2>
          <div className='form-group'>
            <InputField fieldName="address" fieldValue={bol.address} setField={(e) => setBol({ ...bol, [e.target.name]: e.target.value })} type="text" placeholder={"Enter an address"} />
          </div>
          <h2 className='text-center mb-4'>Token Contract Address</h2>
          <div className='form-group'>
            <InputField fieldName="tokenContract" fieldValue={bol.tokenContract} setField={(e) => setBol({ ...bol, [e.target.name]: e.target.value })} type="text" placeholder={"Token Contract Address"} />
          </div>
        </div>
      </div>
      <div className='container'>
        <div className='w-75 mx-auto shadow p-5'>
          <h2 className='text-center mb-4'>Add A BOL</h2>
          <form onSubmit={(e) => onSubmit(e)}>
            {Object.keys(user).map((key, index) => (
              <div className='form-group' key={index}>
                <InputField fieldName={key} fieldValue={user[key]} setField={onInputChange} type="text" placeholder={key} />
              </div>
            ))}
            <button className='btn btn-primary btn-block'>Add BOL</button>
          </form>
        </div>
      </div>
    </div>
  );
};

export default AddUser;
