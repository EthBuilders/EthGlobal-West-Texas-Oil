import React, { useState, useContext } from 'react';
import AppBar from '@material-ui/core/AppBar';
import Toolbar from '@material-ui/core/Toolbar';
import IconButton from '@material-ui/core/IconButton';
import MenuIcon from '@material-ui/icons/Menu';
import Grid from '@material-ui/core/Grid';
import Avatar from '@material-ui/core/Avatar';
import Menu from '@material-ui/core/Menu';
import MenuItem from '@material-ui/core/MenuItem';
import logo from '../../assets/img/logo.png';
import userPhoto from '../../assets/img/user.png';
import { Store } from '../../Store';
import LeftDrawer from './LeftDrawer';
import './Header.scss';

export const Context = React.createContext();

function Header() {
	const { state, dispatch } = useContext(Store);
	const { name } = state.session;

	const [openLeftDrawer, setOpenLeftDrawer] = useState(false);
	const [userMenu, setUserMenu] = useState({
		open: false,
		anchorEl: null
	});

	const doLogout = () => {
		localStorage.clear();
		dispatch({
			type: 'SET_SESSION',
			payload: null
		});
	};

	const contextData = {
		openLeftDrawer,
		setOpenLeftDrawer: (arg) => setOpenLeftDrawer(arg)
	};

	return (
		<Context.Provider value={contextData}>
			<AppBar position="static" className="Header">
				<Toolbar>
					<Grid className="HeaderGrid" container spacing={0}>
						<Grid item>
							<IconButton onClick={() => setOpenLeftDrawer(!openLeftDrawer)} color="inherit" aria-label="Open drawer">
								<MenuIcon />
							</IconButton>
						</Grid>
						<Grid item>
							<img alt="logo" src={logo} style={{ height: 40 }} />
						</Grid>
						<Grid item xs />
						<Grid item>
							{name}
							<IconButton onClick={(e) => setUserMenu({ open: !userMenu.open, anchorEl: e.currentTarget })} color="inherit">
								<Avatar src={userPhoto} />
								<Menu
									anchorEl={userMenu.anchorEl}
									open={userMenu.open}
									onClose={() => setUserMenu(!userMenu.open)}
								>
									<MenuItem onClick={() => doLogout()}>Logout</MenuItem>
								</Menu>
							</IconButton>
						</Grid>
					</Grid>
				</Toolbar>
			</AppBar>
			<LeftDrawer open={openLeftDrawer} />
		</Context.Provider >
	);
}

export default Header;