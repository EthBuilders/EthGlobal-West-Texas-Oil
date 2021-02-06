import React, { useState } from 'react';
import { useHistory } from 'react-router-dom';
import axios from 'axios';
import InputField from "../layout/Input";

const AddUser = () => {
  let history = useHistory();
  const [user, setUser] = useState({
    driver: '',
    serialNumber: '',
    origin: '',
    destination: '',
    quantity: '',
  });

  const { driver, serialNumber, origin, destination, quantity } = user;
  const onInputChange = (e) => {
    setUser({ ...user, [e.target.name]: e.target.value });
  };

  const onSubmit = async (e) => {
    e.preventDefault();
    await axios.post('http://localhost:3003/users', user);
    history.push('/');
  };

  return (
    <div className='container'>
      <div className='w-75 mx-auto shadow p-5'>
        <h2 className='text-center mb-4'>Add A BOL</h2>
        <form onSubmit={(e) => onSubmit(e)}>
          <div className='form-group'>
            <InputField fieldName="driver" fieldValue={driver} setField={onInputChange} type="text" placeholder="Driver Ethereum Address" />
          </div>
          <div className='form-group'>
            <InputField fieldName="serialNumber" fieldValue={serialNumber} setField={onInputChange} type="text" placeholder="Serial Number" />
          </div>
          <div className='form-group'>
            <InputField fieldName="origin" fieldValue={origin} setField={onInputChange} type="text" placeholder="Origin Address" />
          </div>
          <div className='form-group'>
            <InputField fieldName="destination" fieldValue={destination} setField={onInputChange} type="text" placeholder="Destination Address" />
          </div>
          <div className='form-group'>
            <InputField fieldName="quantity" fieldValue={quantity} setField={onInputChange} type="text" placeholder="Quantity of Goods" />
          </div>
          <button className='btn btn-primary btn-block'>Add BOL</button>
        </form>
      </div>
    </div>
  );
};

export default AddUser;
