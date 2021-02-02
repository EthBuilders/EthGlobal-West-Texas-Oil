import React, { useContext } from 'react';
import TextField from '@material-ui/core/TextField';
import Grid from '@material-ui/core/Grid';
import Typography from '@material-ui/core/Typography';
import Button from '@material-ui/core/Button';
import logo from '../../assets/img/logo.png';
import { Store } from '../../Store';
import './Login.scss';

function Login() {
	const { dispatch } = useContext(Store);

	const handleSubmit = () => {
		const user = {
			name: 'Jorge García',
			token: Math.random().toString(36).substring(7)
		};

		localStorage.setItem('session', JSON.stringify(user));
		dispatch({
			type: 'SET_SESSION',
			payload: user
		});
	};

	return (
		<Grid container className="LoginContainer">
			<Grid item xs={8} className="LeftSide"></Grid>
			<Grid item xs={4} className="RightSide">
				<form onSubmit={() => handleSubmit()}>
					<img alt="logo" src={logo} />
					<br />
					<br />
					<Typography variant="h6">
						LOGIN TO YOUR ACCOUNT
					</Typography>
					<TextField
						id="outlined-name"
						type="text"
						margin="normal"
						variant="outlined"
						label="Email"
						fullWidth
						required
					/>
					<TextField
						id="outlined-password-input"
						margin="normal"
						type="password"
						label="Password"
						variant="outlined"
						fullWidth
						required
					/>
					<br />
					<br />
					<Button type="submit" fullWidth>
						LOGIN
					</Button>
				</form>
			</Grid>
		</Grid>
	);
}

export default Login;