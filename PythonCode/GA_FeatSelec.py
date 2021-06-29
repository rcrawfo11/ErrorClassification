from GA import *
from lda import *

class FeatSelectGA(GeneticAlgorithm):
    """
    An example of using the GeneticAlgorithm class to solve a particular
    problem, in this case finding strings with the maximum number of 1's.
    """
    def fitness(self, chromosome):
        """
        Fitness is the sum of the bits.
        """
        return sum(chromosome)

    def isDone(self):
        """
        Stop when the fitness of the the best member of the current
        population is equal to the maximum fitness.
        """
        return self.fitness(self.bestEver) == self.length


def main():
    # use this main program to incrementally test the GeneticAlgorithm
    # class as you implement it
    ga = FeatSelectGA(10, 20)

    # Testing Functions
    #########################################################################
    # #Pop test
    ga.initializePopulation()
    ga.evaluatePopulation()
    #
    # #Select test
    # # for i in range(10):
    # #     selec = ga.selection()
    # #     print("*"*50)
    # #     print(selec)
    # #     print(ga.fitness(selec))
    #
    # #Cross test
    # ga.pCrossover = .4
    # parent1 = ga.selection()
    # parent2 = ga.selection()
    # child1, child2 = ga.crossover(parent1, parent2)
    #
    # #Mutation test
    # ga.pMutation = .1
    # parent1 = ga.selection()
    # print("*"*50)
    # print(parent1)
    # ga.mutation(parent1)
    # print(parent1)
    #
    # #Generation test
    # print("*"*50)
    # print(ga.avgList[0])
    # ga.oneGeneration()
    # ga.evaluatePopulation()
    # print(ga.avgList[1])
    #########################################################################

    # Chromosomes of length 20, population of size 50
    ga = FeatSelectGA(20, 50)
    # Evolve for 100 generations
    # High prob of crossover, low prob of mutation
    bestFound = ga.evolve(100, 0.6, 0.001)
    print(bestFound)
    ga.plotStats("Sum GA")


if __name__ == '__main__':
    main()
