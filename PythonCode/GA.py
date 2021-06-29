import scipy as sp
import random
import pylab
from numpy import array, sum

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
        self.population = []
        chromosome = []
        for i in range(self.popSize):
            for j in range(self.length):
                chromosome.append(random.randint(0,1))
            self.population.append(chromosome)
            chromosome = []


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
        total_fit = 0
        temp_score = []

        for i in range(self.popSize):

            fit_score = self.fitness(self.population[i])
            temp_score.append(fit_score)

            if fit_score > self.bestEverScore:
                self.bestEverScore = fit_score
                self.bestEver = self.population[i]
                print("New best found:", fit_score, "\n")

            total_fit += fit_score

        self.scores = temp_score.copy()
        self.totalFitness = total_fit

        #print("avgList:", self.avgList, "\n", "*"*50, "\n bestList:", self.bestList)
        self.avgList.append(total_fit/self.popSize)
        self.bestList.append(self.bestEverScore)


    def selection(self):
        """
        Each chromosome's chance of being selected for reproduction is
        based on its fitness.  The higher the fitness the more likely
        it will be selected.  Uses the roulette wheel strategy on
        self.scores.
        Returns: A COPY of the selected chromosome.


        CHANGE TO MATCH STUDY
        """
        spin = random.random()*self.totalFitness
        partialProb = 0
        for i in range(self.popSize):
            partialProb += self.scores[i]
            if partialProb >= spin:
                index = i
                break

        selected = self.population[index]
        return selected

    def crossover(self, parent1, parent2):
        """
        With probability self.pCrossover, recombine the genetic
        material of the given parents at a random location between
        1 and the length-1 of the chromosomes. If no crossover is
        performed, then return the original parents.

        Parameters: parent1, parent2

        Returns: Two children
        """
        cross = False
        for i in range(1, self.length):
            if self.pCrossover > random.random():
                child1 = parent1[0:i] + parent2[i:self.length]
                child2 = parent2[0:i] + parent1[i:self.length]
                cross = True
                #child1 = child1[0]
                #child2 = child2[0]
                break
        if cross == False:
            child1 = parent1.copy()
            child2 = parent2.copy()

        return child1, child2

    def mutation(self, chromosome):
        """
        With probability self.pMutation tested at each position in the
        chromosome, flip value.
        Returns: None
        """
        for i in range(self.length):
            if self.pMutation > random.random():
                #update to XOR in Cython implemetation?
                chromosome[i] = (chromosome[i]+1)%2

    def oneGeneration(self):
        """
        Execute one generation of the evolution. Each generation,
        repeatedly select two parents, call crossover to generate two
        children.  Call mutate on each child.  Finally add both
        children to the new population.  Continue until the new
        population is full. Replaces self.pop with a new population.
        Returns: None
        """
        tempPop = []
        self.evaluatePopulation()
        while len(tempPop) < self.popSize:

            parent1 = self.selection()
            parent2 = self.selection()

            child1, child2  = self.crossover(parent1, parent2)

            self.mutation(child1)
            self.mutation(child2)

            tempPop.append(child1)
            tempPop.append(child2)

        self.population = tempPop.copy()


    def evolve(self, maxGen, pCrossover=0.7, pMutation=0.001):
        """
        Run a series of generations until a maximum generation is
        reached or self.isDone() returns True.
        Returns the best chromosome ever found over the course of
        the evolution, which is stored in self.bestEver.
        """

        self.pCrossover = pCrossover
        self.pMutation = pMutation
        self.initializePopulation()
        for i in range(maxGen):
            self.oneGeneration()
            self.generation += 1
            if self.isDone():
                break

        return self.bestEver

    def plotStats(self, title=""):
        """
        Plots a summary of the GA's progress over the generations.
        Adds the given title to the plot.
        """
        print("avgList:", self.avgList, "\n", "*"*50, "\n bestList:", self.bestList)
        gens = range(self.generation) #had generation+1 not sure why
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
