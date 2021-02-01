import React from 'react';
import { BrowserRouter } from 'react-router-dom';
import Routes from '../../Routes';
import Header from '../../components/Header/Header';
import './Home.scss';

function Home() {
	return (
		<BrowserRouter>
			<Header />
			<section className="HomeContainer">
				<Routes />
			</section>
		</BrowserRouter>
	);
}

export default Home;