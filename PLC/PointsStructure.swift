//
//  PointsStructure.swift
//  PLC
//
//  Created by Connor Eschrich on 7/26/18.
//  Copyright © 2018 Chris Chou. All rights reserved.
//

struct Points{
    func getPoints(type: String, thisTask: Task!)->Int{
        var isLead = false
        var isParticipant = false
        var isCreate = false
        var points =  Int()
        if type == "Lead"{
            isLead = true
        }
        else if type == "Create"{
            isCreate = true
        }
        else{
            isParticipant = true
        }
        
        if thisTask!.category == "Fun & Games" {
            if isLead{
                points = getLeaderPoints(thisTask: thisTask)
            }
            if isParticipant{
                points = getParticipantPoints(thisTask: thisTask)
            }
            if isCreate{
                points = 100
            }
        }
        else if thisTask!.category == "Philanthropy" {
            if isLead{
                points = getLeaderPoints(thisTask: thisTask) * 7 / 4
            }
            if isParticipant{
                points = getParticipantPoints(thisTask: thisTask) * 7 / 4
            }
            if isCreate{
                points = 100 * 7 / 4
            }
        }
        else if thisTask!.category == "Shared Interests" {
            if isLead{
                points = getLeaderPoints(thisTask: thisTask) * 3 / 2
            }
            if isParticipant{
                points = getParticipantPoints(thisTask: thisTask) * 3 / 2
            }
            if isCreate{
                points = 100 * 3 / 2
            }
        }
        else if thisTask!.category == "Skill Building" {
            if isLead{
                points = getLeaderPoints(thisTask: thisTask) * 2
            }
            if isParticipant{
                points = getParticipantPoints(thisTask: thisTask) * 2
            }
            if isCreate{
                points = 100 * 2
            }
        }
        else {
            if isLead{
                points = getLeaderPoints(thisTask: thisTask) * 5 / 4
            }
            if isParticipant{
                points = getParticipantPoints(thisTask: thisTask) * 5 / 4
            }
            if isCreate{
                points = 100 * 5 / 4
            }
        }
        return points
    }
    
    private func getLeaderPoints(thisTask: Task)-> Int{
        var leaderPts = Int((thisTask.endTimeMilliseconds - thisTask.timeMilliseconds) / 200)
        if leaderPts / 10 < 35 {
            leaderPts = 35
        }
        else {
            leaderPts /= 10
            if leaderPts > 100 {
                leaderPts = 100
            }
        }
        return leaderPts
    }
    
    private func getParticipantPoints(thisTask: Task)-> Int{
        var participantPts = Int((thisTask.endTimeMilliseconds - thisTask.timeMilliseconds) / 1000)
        if participantPts / 10 < 5 {
            participantPts = 5
        }
        else {
            participantPts /= 10
            if participantPts > 20 {
                participantPts = 20
            }
        }
        return participantPts
    }
}
