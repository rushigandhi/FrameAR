import React from 'react';
import './App.css';
import Grid from '@material-ui/core/Grid';
import { makeStyles } from '@material-ui/core/styles';
import Paper from '@material-ui/core/Paper';

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
    <Grid container
    direction="column"
    justify="space-in-between"
    alignItems="stretch">
    <Paper className={classes.paper}>xs=12 sm=6</Paper>
    <Paper className={classes.paper}>xs=12 sm=6</Paper>
    <Paper className={classes.paper}>xs=12 sm=6</Paper>
    <Paper className={classes.paper}>xs=12 sm=6</Paper>
  </Grid>
  );
}
