import React from 'react';
import Card from '@material-ui/core/Card';
import Typography from '@material-ui/core/Typography';
import CardActionArea from '@material-ui/core/CardActionArea';
import CardContent from '@material-ui/core/CardContent';
import CardMedia from '@material-ui/core/CardMedia';

function CardComponent(props) {
	const album = props.data;
	return (
		<Card>
			<CardActionArea>
				<CardMedia
					component="img"
					alt="alt text"
					image={album['im:image'][2].label}
					title="title text"
				/>
				<CardContent>
					<Typography gutterBottom>
						{album.title.label}
					</Typography>
				</CardContent>
			</CardActionArea>
		</Card>
	);
}

export default CardComponent;