import React from 'react';
import { Helmet } from 'react-helmet'
import './App.css';
import CssBaseline from '@material-ui/core/CssBaseline';
import Container from '@material-ui/core/Container';
import Grid from '@material-ui/core/Grid';
import Paper from '@material-ui/core/Paper'
import { makeStyles } from '@material-ui/core/styles';
import graphGit from './Gitgraph'

const useStyles = makeStyles(theme => ({
  root: {
    flexGrow: 1,
  },
  paper: {
    padding: theme.spacing(2),
    textAlign: 'center',
    color: theme.palette.text.secondary,
  },
}));

export default function App() {
  const classes = useStyles();

  return (
    <React.Fragment>
      <helmet>
        <style>{'body { background-color: #282c34; }'}</style>
      </helmet>
      <CssBaseline />
      <Container maxWidth="sm">
      <Grid>
        <Grid item xs={12}>
          <Paper className={classes.paper}>xs=12</Paper>
          <Paper className={classes.paper}>
            <graphGit/>
          </Paper>
        </Grid>
      </Grid>
      </Container>
    </React.Fragment>
  );
}
