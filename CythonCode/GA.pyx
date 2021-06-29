import scipy as sp
import random
import pylab

class GeneticAlgorithm(object):
    """
    A genetic algorithm is a model of biological evolution.  It
    maintains a population of chromosomes.  Each chromosome is
    represented as a list of 0's and 1's.  A fitness function must be
    defined to score each chromosome.  Initially, a random population
    is created. Then a series of generations are executed.  Each
    generation, parents are selected from the population based on
    their fitness.  More highly fit chromosomes are more likely to be
    selected to create children.  With some probability crossover will
    be done to model sexual reproduction.  With some very small
    probability mutations will occur.  A generation is complete once
    all of the original parents have been replaced by children.  This
    process continues until the maximum generation is reached or when
    the isDone method returns True.
    """
    def __init__(self, length, popSize, verbose=False):
        self.verbose = verbose      # Set to True to see more info displayed
        self.length = length        # Length of the chromosome
        self.popSize = popSize      # Size of the population
        self.bestEver = None        # Best member ever in this evolution
        self.bestEverScore = 0      # Fitness of best member ever
        self.population = None      # Population is a list of chromosomes
        self.scores = None          # Fitnesses of all members of population
        self.totalFitness = None    # Total fitness in entire population
        self.generation = 0         # Current generation of evolution
        self.maxGen = 100           # Maximum generation
        self.pCrossover = None      # Probability of crossover
        self.pMutation = None       # Probability of mutation (per bit)
        self.bestList = []          # Best fitness per generation
        self.avgList = []           # Avg fitness per generation
        print("Executing genetic algorithm")
        print("Chromosome length:", self.length)
        print("Population size:", self.popSize)

    def initializePopulation(self):
        """
        Initialize each chromosome in the population with a random
        series of 1's and 0's.
        Returns: None
        Result: Initializes self.population
        """
        raise NotImplementedError("TODO")

    def evaluatePopulation(self):
        """
        Computes the fitness of every chromosome in population.  Saves the
        fitness values to the list self.scores.  Checks whether the
        best fitness in the current population is better than
        self.bestEverScore. If so, prints a message that a new best
        was found and its score, updates this variable and saves the
        chromosome to self.bestEver.  Computes the total fitness of
        the population and saves it in self.totalFitness. Appends the
        current bestEverScore to the self.bestList, and the current
        average score of the population to the self.avgList.
        Returns: None
        """
        raise NotImplementedError("TODO")

    def selection(self):
        """
        Each chromosome's chance of being selected for reproduction is
        based on its fitness.  The higher the fitness the more likely
        it will be selected.  Uses the roulette wheel strategy on
        self.scores.
        Returns: A COPY of the selected chromosome.
        """
        raise NotImplementedError("TODO")

    def crossover(self, parent1, parent2):
        """
        With probability self.pCrossover, recombine the genetic
        material of the given parents at a random location between
        1 and the length-1 of the chromosomes. If no crossover is
        performed, then return the original parents.
        Returns: Two children
        """
        raise NotImplementedError("TODO")

    def mutation(self, chromosome):
        """
        With probability self.pMutation tested at each position in the
        chromosome, flip value.
        Returns: None
        """
        raise NotImplementedError("TODO")

    def oneGeneration(self):
        """
        Execute one generation of the evolution. Each generation,
        repeatedly select two parents, call crossover to generate two
        children.  Call mutate on each child.  Finally add both
        children to the new population.  Continue until the new
        population is full. Replaces self.pop with a new population.
        Returns: None
        """
        raise NotImplementedError("TODO")

    def evolve(self, maxGen, pCrossover=0.7, pMutation=0.001):
        """
        Run a series of generations until a maximum generation is
        reached or self.isDone() returns True.
        Returns the best chromosome ever found over the course of
        the evolution, which is stored in self.bestEver.
        """
        raise NotImplementedError("TODO")

    def plotStats(self, title=""):
        """
        Plots a summary of the GA's progress over the generations.
        Adds the given title to the plot.
        """
        gens = range(self.generation+1)
        pylab.plot(gens, self.bestList, label="Best")
        pylab.plot(gens, self.avgList, label="Average")
        pylab.legend(loc="upper left")
        pylab.xlabel("Generations")
        pylab.ylabel("Fitness")
        if len(title) != 0:
            pylab.title(title)
        pylab.show()

    def fitness(self, chromosome):
        """
        The fitness function will change for each problem.  Therefore
        it is not defined here.  To use this class to solve a
        particular problem, inherit from this class and define this
        method.
        """
        # Override this
        pass

    def isDone(self):
        """
        The stopping critera will change for each problem.  Therefore
        it is not defined here.  To use this class to solve a
        particular problem, inherit from this class and define this
        method.
        """
        # Override this
        pass
