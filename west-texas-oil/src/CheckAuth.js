import React, { useContext } from 'react';
import Home from './containers/Home/Home';
import Login from './containers/Login/Login';
import { Store } from './Store';

function CheckAuth() {	
	const { state, dispatch } = useContext(Store);

	const lsuser = localStorage.getItem('session');
	if (!state.session && lsuser !== null) {
		dispatch({
			type: 'SET_SESSION',
			payload: JSON.parse(lsuser)
		});
	}

	const content = (state.session && state.session !== null) ? <Home /> : <Login />;
	return content;
}

export default CheckAuth;