import csv
import random
import math

def loadCsv(filename):
	lines = csv.reader(open(filename, 'rt'))
	dataset = list(lines)
	dataset = dataset[1:]
	for i in range(len(dataset)):
		dataset[i] = [float(x) for x in dataset[i]]
	return dataset

def splitDataset(dataset, splitratio):
	trainingSize = int(len(dataset)*splitratio)
	trainSet=[]
	copy = list(dataset)
	while(len(trainSet)<trainingSize):
		index = random.randrange(len(copy))
		trainSet.append(copy.pop(index))
	return [trainSet , copy]

def mean(numbers):
	return sum(numbers)/float(len(numbers))

def stddev(numbers):
	avg = mean(numbers)
	variance = sum([pow(x-avg,2) for x in numbers])/float(len(numbers)-1)
	return math.sqrt(variance)

def summarize(instances):
	summaries = [(mean(attribute), stddev(attribute)) for attribute in  zip(*instances)]
	del summaries[-1]
	return summaries	

def summarizeByClass(trainSet):
	seperated = seperateByClass(trainSet)
	summaries = {}
	for classValue , instances in seperated.items():
		summaries[classValue] = summarize(instances)
	return summaries

def seperateByClass(trainSet):
	seperated={}
	for i in range(len(trainSet)):
		vector = trainSet[i]
		if vector[-1] not in seperated:
			seperated[vector[-1]] = []
		seperated[vector[-1]].append(vector)
	return seperated

def calculateProbability(x,mean,stddev):
	exponent = math.exp(-(math.pow(x-mean,2)/(2*math.pow(stddev,2))))
	return (1 / (math.sqrt(2*math.pi) * stddev)) * exponent

def calculateClassProbabilities(summaries, inputVector):
	probabilities = {}
	for classValue, classSummaries in summaries.items():
		probabilities[classValue] = 1
		for i in range(len(classSummaries)):
			mean , stddev = classSummaries[i]
			x = inputVector[i]
			probabilities[classValue] *= calculateProbability(x,mean,stddev)
	return probabilities

def predict(summaries, inputVector):
	probabilities =calculateClassProbabilities(summaries, inputVector)
	bestLabel , bestClass = None , -1
	for classValue, probability in probabilities.items():
		if bestLabel is None or probability > bestProb:
			bestProb = probability
			bestLabel = classValue
	return bestLabel


def getPredictions(summaries, testSet):
	predictions = []
	for i in range(len(testSet)):
		result = predict(summaries, testSet[i])
		predictions.append(result)
	return predictions

def getAccuracy(predictions, testSet):
	correct = 0
	for i in range(len(testSet)):
		if predictions[i]==testSet[i][-1]:
			correct += 1
	return (correct/float(len(testSet)))*100


def main():

	dataset = loadCsv('diabetes.csv')

	splitratio = 0.70

	trainSet, testSet = splitDataset(dataset, splitratio)

	summaries = summarizeByClass(trainSet)

	predictions = getPredictions(summaries, testSet)

	accuracy = getAccuracy(predictions, testSet)

	print ("accuracy = ", accuracy)

main()