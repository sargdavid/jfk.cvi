#################################Program Description################################
#Name: create matches                                                              #
#Author: Traymon Beavers                                                           #
#Depends: upload data.R, interpolate.R, matching.R, final matching.R               #
#Date Created: 7/21/2017                                                           #
#Date Updated: 9/13/2017                                                           #
#Purpose: To find, create, and extract the set of matches which contains the most  #
#         patients, the least missing data, and the most deceased patient          #
####################################################################################

# Notes about specific sets of one to one matches #############
# (5, 25, 25, 25, 1, 2) yields 62 out of 88 study ID matches  #
# 49 unique controls out of an original 128                   #
# 726 nonmissing obs with seed 966                            #
# maximum is 49 and 728                                       # 
#                                                             #
# (10, 25, 25, 25, 1, 2) yields 71 out of 88 study ID matches #
# 49 unique controls out of an original 164                   #
# 805 nonmissing obs                                          #
# 4 deceased patients with seed 963                           #
# maximum is 49 and 805                                       #
#                                                             #
# (8, 25, 25, 25, 1, 2) yields 67 out of 88 study ID matches  #
# with seed 370:                                              #
# 49 unique controls out of an original 154                   #
# 769 nonmissing obs                                          #
# 6 deceased patients                                         #
# maximum is 49, 770, and 9                                   #
###############################################################

# Load the necessary source code and functions ####
source("source/Traymon's Source Code/Data Reconfiguration/upload data.R")
source("source/Traymon's Source Code/Data Reconfiguration/interpolate.R")
source("source/Traymon's Source Code/Functions/Matching Functions/matching.R")
source("source/Traymon's Source Code/Functions/Matching Functions/final matching.R")

# Optimize set of matches ####

# create matches
matchrows = matching(AgeNum = 8,
                     DischargeMobNum = 25,
                     DischargeActNum = 25,
                     DischargeCogNum = 25,
                     PScoreNum = 1,
                     FacAdjNum = 2)

# count the number of unique patients in the subset of matched patients
length(unique(matchrows[matchrows[, "Group"] == 1, "ID"]))
length(unique(matchrows[matchrows[, "Group"] == 0, "ID"]))

# count the number of deceased patients in the subset of matched patients
sum(NewMaster.One[NewMaster.One[,"ID"] %in% unique(matchrows[matchrows[, "Group"] == 0, "ID"]), "Deceased_Y.N"])

# # Find the seed that optimizes the set of one to one matches ####
# 
# # initialize vector to hold the number of non-missing observations this collection of matches has
# NA.Num = 0
# 
# # initialize vector to hold the number of unique control group patients this collection of matches has
# UC.Num = 0
# 
# # initialize vector to hold the number of deceased patients this collection of matches has
# DC.Num = 0
# 
# # cycle through 1000 seeds
# for (k in 1:1000){
# 
#   # initialize the matrix to hold the set of one to one matches
#   matchrow.final = c(0,0,0)
# 
#   # cycle through the unique study patients in the matches created
#   for (i in unique(matchrows[matchrows[, "Group"] == 1, "ID"])){
# 
#     # set the seed
#     set.seed(k)
# 
#     # count the number of control patients matched to this study patient
#     N = length(which(matchrows[, "ID"] == i))
# 
#     # randomly choose which control patient will be moved to the one-to-one set of matches
#     j = ceiling(runif(1, 0, N))
# 
#     # update the set of one to one matches to include the new match
#     matchrow.final = rbind(matchrow.final,
#                            matchrows[which(matchrows[, "ID"] == i)[j], ],
#                            matchrows[(which(matchrows[, "ID"] == i)[j] + 1), ])
# 
# 
#   }
# 
#   # delete the initial 0's
#   matchrow.final = matchrow.final[-1, ]
# 
#   # initialize the number of non missing observations
#   Non.Missing.Num = 0
# 
#   # cycle through the IDs in the set of one to one matches
#   for (j in unique(matchrow.final[, "ID"])){
# 
#     # update the number of non missing observations to include the number of non missing
#     # observations this ID has
#     Non.Missing.Num = Non.Missing.Num + length(Interpolate.Master[Interpolate.Master[, "ID"] == j &
#                                                                     Interpolate.Master[, "DaysId"] >= 1 &
#                                                                     Interpolate.Master[, "DaysId"] <= 8,
#                                                                   "PT.AM.PAC.Basic.Mobility.Score"]) -
#       sum(is.na(Interpolate.Master[Interpolate.Master[, "ID"] == j &
#                                      Interpolate.Master[, "DaysId"] >= 1 &
#                                      Interpolate.Master[, "DaysId"] <= 8,
#                                    "PT.AM.PAC.Basic.Mobility.Score"]))
# 
# 
#   }
# 
#   # update NA.Num to include the number of non missing observations for this set of one to one matches
#   NA.Num = c(NA.Num, Non.Missing.Num)
# 
#   # update UC.Num to include the number of unique controls for this set of one to one matches
#   UC.Num = c(UC.Num, length(unique(matchrow.final[matchrow.final[, "Group"] == 0, "ID"])))
# 
#   # update UC.Num to include the number of unique controls for this set of one to one matches
#   DC.Num = c(DC.Num, sum(NewMaster.One[NewMaster.One[,"ID"] %in% matchrow.final[, "ID"], "Deceased_Y.N"]))
# 
#   # print seeds that have number of non missing observations and unique controls above a desired threshold
#   if (length(unique(matchrow.final[matchrow.final[, "Group"] == 0, "ID"])) > 47 &
#       sum(NewMaster.One[NewMaster.One[,"ID"] %in% matchrow.final[, "ID"], "Deceased_Y.N"]) > 5){
# 
#     print(k)
#     print(c(length(unique(matchrow.final[matchrow.final[, 3] == 0, "ID"])),
#             Non.Missing.Num,
#             sum(NewMaster.One[NewMaster.One[,"ID"] %in% matchrow.final[, "ID"], "Deceased_Y.N"])))
# 
#   }
# 
# }
# 
# # check what the maximum number of missing observations, maximum number of unique controls
# # and deceased patients are
# max(NA.Num)
# max(UC.Num)
# max(DC.Num)

# Create the matches and extract the data for all patients in the set of one to one matches ####

# create the matches
matchrow.final = final.matching(Matchrows = matchrows,
                                Match.seed = 370)

# extract the data
match.subgroup = Interpolate.Master[Interpolate.Master[,"ID"] %in% matchrow.final[, "ID"], ]
match.subgroup.One = NewMaster.One[NewMaster.One[,"ID"] %in% matchrow.final[, "ID"], ]
match.subgroup.One.Study = match.subgroup.One[match.subgroup.One[, "Group"] == "Study Group", ]
match.subgroup.One.Control = match.subgroup.One[match.subgroup.One[, "Group"] == "Control Group", ]
