import React, { useState } from 'react';
import { useHistory } from 'react-router-dom';
import axios from 'axios';
import InputField from "../layout/Input";
import Web3 from 'web3';
import { fs } from 'fs';

const AddUser = () => {
  let history = useHistory();
  let [bol, setBol] = useState({ address: "0x0000000000000000000000000000000000000000", tokenContract: "0x0000000000000000000000000000000000000000" });
  const [user, setUser] = useState({
    driver: '',
    serialNumber: '',
    originDegrees: '',
    originMinutes: '',
    originSeconds: '',
    originCardinalDirection: '',
    destinationDegrees: '',
    destinationMinutes: '',
    destinationSeconds: '',
    destinationCardinalDirection: '',
    quantity: '',
  });

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

    await loadWeb3();
    let web3 = new Web3(window.web3.currentProvider);

    let bolContract = new web3.eth.Contract(JSON.parse(fs.readFileSync('../../../../backend/build/contracts/BillOfLading.json', 'utf8')), bol.address);
    await bolContract.methods.createBillOfLading(
      [user.driver, user.serialNumber, [
        parseInt(user.originDegrees),
        parseInt(user.originMinutes),
        parseInt(user.originSeconds),
        parseInt(user.originCardinalDirection)
      ], [
        parseInt(user.destinationDegrees),
        parseInt(user.destinationMinutes),
        parseInt(user.destinationSeconds),
        parseInt(user.destinationCardinalDirection)
      ], parseInt(user.quantity)],
      bol.tokenContract,
      100
    ).send();


    history.push('/');
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
