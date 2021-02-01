import React from 'react';
import { Route, Switch } from 'react-router-dom';

import Page404 from './components/Page404/Page404';
import Page1 from './containers/Page1/Page1';
import Page2 from './containers/Page2/Page2';

function Routes() {
	return (
		<Switch>
			<Route path="/" exact component={Page1} />
			<Route path="/page1" exact component={Page1} />
			<Route path="/page2" exact component={Page2} />
			<Route component={Page404} />
		</Switch>
	);
}

export default Routes;