import React, { useState } from 'react';
import { useHistory } from 'react-router-dom';
import axios from 'axios';
import InputField from "../layout/Input";

const AddUser = () => {
  let history = useHistory();
  let [bol, setBol] = useState({ address: "0x0000000000000000000000000000000000000000" });
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

  // const { driver, serialNumber, origin, destination, quantity } = user;
  const onInputChange = (e) => {
    setUser({ ...user, [e.target.name]: e.target.value });
  };

  const onSubmit = async (e) => {
    e.preventDefault();
    await axios.post('http://localhost:3003/users', user);
    history.push('/');
  };

  return (
    <div>
      <div className='container'>
        <div className='w-75 mx-auto shadow p-5'>
          <h2 className='text-center mb-4'>BOL Contract Address</h2>
          <InputField fieldName="address" fieldValue={bol.address} setField={(e) => setBol({ [e.target.name]: e.target.value })} type="text" placeholder={"Enter an address"} />
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
