import React, { useState, useEffect } from 'react';
import { Link, useParams } from 'react-router-dom';
import axios from 'axios';

const User = () => {
  const [user, setUser] = useState({
    driver: '',
    serialNumber: '',
    origin: '',
    destination: '',
    quantity: '',
  });
  const { id } = useParams();
  useEffect(() => {
    loadUser();
  }, []);
  const loadUser = async () => {
    const res = await axios.get(`http://localhost:3003/users/${id}`);
    setUser(res.data);
  };
  return (
    <div className='container py-4'>
      <Link className='btn btn-primary' to='/'>
        back to Home
      </Link>
      <h1 className='display-4'>User Id: {id}</h1>
      <hr />
      <ul className='list-group w-50'>
        <li className='list-group-item'>Driver: {user.driver}</li>
        <li className='list-group-item'>Serial Number: {user.serialNumber}</li>
        <li className='list-group-item'>Origin: {user.origin}</li>
        <li className='list-group-item'>Destination: {user.destination}</li>
        <li className='list-group-item'>Quantity: {user.quantity}</li>
      </ul>
    </div>
  );
};

export default User;
