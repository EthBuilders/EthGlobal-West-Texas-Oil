import React, { useState, useEffect } from 'react';
import axios from 'axios';
import { Link } from 'react-router-dom';
import InputField from "../layout/Input";
import Web3 from 'web3';
const bolAbi = require("../../bol.json");



const Home = () => {
  let [bol, setBol] = useState({ address: "0x0000000000000000000000000000000000000000", tokenContract: "0x0000000000000000000000000000000000000000" });
  const [users, setUser] = useState([]);

  let account;

  useEffect(() => {
    loadUsers();
    loadWeb3();
  }, []);

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

  const loadUsers = async () => {

    window.web3.currentProvider.enable();
    let web3 = new Web3(window.web3.currentProvider);

    web3.eth.getAccounts().then((e) => {

      let bolContract = new web3.eth.Contract(bolAbi.abi, bol.address, { from: account });

      bolContract.getPastEvents("allevents", { fromBlock: 1, toBlock: "latest" }).then((events) => {
        console.log(events);
        setUser(events);
      })

      // setUser(result.data.reverse());
    })

  };

  const deleteUser = async (id) => {
    await axios.delete(`http://localhost:3003/users/${id}`);
    loadUsers();
  };

  return (
    <div className='container'>
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
      <div className='py-4'>
        <h1>Home Page</h1>
        {users.map((user, index) => (
          <div>
            <p>{index}</p>
            <p>{user}</p>
          </div>
        ))}
        {/* <table class='table border shadow'>
          <thead class='thead-dark'>
            <tr>
              <th scope='col'>#</th>
              <th scope='col'>Name</th>
              <th scope='col'>User Name</th>
              <th scope='col'>Email</th>
              <th>Action</th>
            </tr>
          </thead>
          <tbody>
            {users.map((user, index) => (
              <tr>
                <th scope='row'>{index + 1}</th>
                <td>{user.driver}</td>
                <td>{user.serialNumber}</td>
                <td>{user.origin}</td>
                <td>
                  <Link class='btn btn-primary mr-2' to={`/users/${user.id}`}>
                    View
                  </Link>
                  <Link
                    class='btn btn-outline-primary mr-2'
                    to={`/users/edit/${user.id}`}
                  >
                    Edit
                  </Link>
                  <Link
                    class='btn btn-danger'
                    onClick={() => deleteUser(user.id)}
                  >
                    Delete
                  </Link>
                </td>
              </tr>
            ))} */}
        {/* </tbody>
        </table> */}
      </div >
    </div >
  );
};

export default Home;
