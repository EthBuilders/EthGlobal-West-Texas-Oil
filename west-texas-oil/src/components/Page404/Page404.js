import React from 'react';
import Image404 from '../../assets/img/404.gif';

function Page404() {
	const containerStyle = {
		display: 'flex',
		flexDirection: 'column',
		justifyContent: 'center',
		alignItems: 'center'
	};
	return (
		<div style={containerStyle}>
			<img alt="404" src={Image404} />
		</div>
	);
};

export default Page404;