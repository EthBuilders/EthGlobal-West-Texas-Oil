import React, { useState } from 'react';
import { useHistory } from 'react-router-dom';
import axios from 'axios';

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
            <input
              type='text'
              className='form-control form-control-lg'
              placeholder='Driver Ethereum Address'
              name='driver'
              value={driver}
              onChange={(e) => onInputChange(e)}
            />
          </div>
          <div className='form-group'>
            <input
              type='text'
              className='form-control form-control-lg'
              placeholder='Serial Number'
              name='serialNumber'
              value={serialNumber}
              onChange={(e) => onInputChange(e)}
            />
          </div>
          <div className='form-group'>
            <input
              type='text'
              className='form-control form-control-lg'
              placeholder='Origin Address'
              name='origin'
              value={origin}
              onChange={(e) => onInputChange(e)}
            />
          </div>
          <div className='form-group'>
            <input
              type='text'
              className='form-control form-control-lg'
              placeholder='Destination Address'
              name='destination'
              value={destination}
              onChange={(e) => onInputChange(e)}
            />
          </div>
          <div className='form-group'>
            <input
              type='text'
              className='form-control form-control-lg'
              placeholder='Quantity of Goods'
              name='quantity'
              value={quantity}
              onChange={(e) => onInputChange(e)}
            />
          </div>
          <button className='btn btn-primary btn-block'>Add BOL</button>
        </form>
      </div>
    </div>
  );
};

export default AddUser;
