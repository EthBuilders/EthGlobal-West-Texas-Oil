import React, { useState, useEffect } from 'react';
import Web3 from 'web3';

const Metamask = () => {

  let [login, setLogin] = useState(false);

  // loads the metamask extension
  // TODO: make it only load when we click a button
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

  // load the metamask extension
  useEffect(() => {
    if (login) {
      document.getElementById("metamaskLogin").style.display = "none";
    }
  }, [login]);

  return (
    <div id="metamaskLogin">
      <button onClick={async (e) => {
        await loadWeb3();
        setLogin(true);
      }}
      type="button">
        Sign into Metamask
      </button>
    </div>
    

  );
}


export default Metamask;