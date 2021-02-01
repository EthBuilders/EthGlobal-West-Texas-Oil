import React, { useState, useEffect, Suspense, lazy } from 'react';
import axios from 'axios';
import Grid from '@material-ui/core/Grid';
import './Page1.scss';
import imgLoader from '../../assets/img/loader.gif';
const CardComponent = lazy(() => import('./CardComponent'));

function Page1() {

	const [albums, setAlbums] = useState([]);
	useEffect(() => {
		const fetchData = async () => {
			try {
				const result = await axios('https://itunes.apple.com/in/rss/topalbums/limit=100/json');
				setAlbums(result.data.feed.entry);
			} catch (error) {
				console.log(error);
			}
		};

		fetchData();
	}, []);

	const loading = <div className="album-img">
		Loading..
		<img alt="loading" src={imgLoader} />
	</div>;

	return (
		<Grid container spacing={24}>
			{
				albums.map((album) =>
					<Grid key={album.id.label} item xs={3}>
						<Suspense fallback={loading}>
							<CardComponent data={album} />
						</Suspense>
					</Grid>
				)
			}
		</Grid>
	);
}

export default Page1;