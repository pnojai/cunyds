---
title       : Data Science in Context
subtitle    : Sulzer Neuroscience Laboratory at Columbia University
author      : Jai Jeffryes
job         : Data analyst and programmer
framework   : io2012        # {io2012, html5slides, shower, dzslides, ...}
highlighter : highlight.js  # {highlight.js, prettify, highlight}
hitheme     : tomorrow      # 
widgets     : []            # {mathjax, quiz, bootstrap}
mode        : selfcontained # {standalone, draft}
knit        : slidify::knit2slides
---

<style>
.title-slide {
  background-color: #FFFFFF; /* #EDE0CF; ; #CA9F9D*/
}
</style>

<img src="./assets/img/SulzerLab.jpg" width="80%"/>

- Dr. David Sulzer, Principal Investigator
- Jai
- Dr. Mahalakshmi Somayaji, Post-Doctoral Researcher

---

## Dopamine kinetics
![](./assets/img/Neuron.jpg) ![](./assets/img/Synapse_Illustration2_tweaked.jpg)



[^1]: Typical neuron: Public Domain, https://commons.wikimedia.org/w/index.php?curid=254226
[^2]: Vesicles: Creative Commons, https://commons.wikimedia.org/w/index.php?curid=4001388

---

## Random Walk
- Release
- Diffusion
- Reuptake

![](./assets/img/RandomWalkScreen.jpg)

---

## Michaelis-Menten Equation
- Reuptake

![](./assets/img/MM_equation.png)

---

## Simulation of DA concentration
![](./assets/img/Sim1.jpeg) ![](./assets/img/Sim2.jpeg) 

---

## Experimental data
- Stimulate each two minutes.
- Amphetamine begins in fourth stimulus.
- Biological variability.
- DA concentration is **net** of release and reuptake.

![](./assets/img/animal1.jpeg)

--- 

## Fitting the model
Infer kinetics of DA
- Release
- km (reuptake)
- R-squared

![](./assets/img/animal_fit_before.jpeg) ![](./assets/img/animal_fit_after.jpeg)

--- 

## Wrap up
- Mechanism of AMPH-evoked DA release.
- Controlled experiment using genotypes.
- Publication.
- Rwalk package on GitHub: [https://github.com/pnojai/rwalk](https://github.com/pnojai/rwalk)
