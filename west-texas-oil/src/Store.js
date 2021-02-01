import React, { useReducer } from 'react';

export const Store = React.createContext();

const initialState = {
	session: null
};

const globalReducer = (state = initialState, action) => {
	switch (action.type) {
	case 'SET_SESSION':
		return { ...state, session: action.payload };
	default:
		return state;
	}
};

export function StoreProvider(props) {
	const [state, dispatch] = useReducer(globalReducer, initialState);
	const value = { state, dispatch };
	return <Store.Provider value={value}>{props.children}</Store.Provider>;
}