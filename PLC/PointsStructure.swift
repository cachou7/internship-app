//
//  PointsStructure.swift
//  PLC
//
//  Created by Connor Eschrich on 7/26/18.
//  Copyright © 2018 Chris Chou. All rights reserved.
//

struct Points{
    
    // Input user role (creator, leader, participant) and task, return number of points
    func getPoints(type: String, thisTask: Task!)->Int{
        
        // MARK: Initialize
        var isLead = false
        var isParticipant = false
        var isCreate = false
        var points =  Int()
        
        // Set user role
        if type == "Lead"{
            isLead = true
        }
        else if type == "Create"{
            isCreate = true
        }
        else{
            isParticipant = true
        }
        
        // Set task categories
        // Fun & Games (x1 multiplier)
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
        // Philanthropy (x1.75 multiplier)
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
        // Shared Interests (x1.5 multiplier)
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
        // Skill Building (x2 multiplier)
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
        // Other (x1.25 multiplier)
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
    
    // Returns the number of points for leading a task
    private func getLeaderPoints(thisTask: Task)-> Int{
        // Get duration of task in seconds
        var leaderPts = Int((thisTask.endTimeMilliseconds - thisTask.timeMilliseconds) / 60)
        
        // Set min points at 30
        if leaderPts / 2 < 30 {
            leaderPts = 30
        }
        // Increased task duration increases point value up to 100
        else {
            leaderPts /= 3
            if leaderPts < 30 {
                leaderPts = 30
            }
            if leaderPts > 100 {
                leaderPts = 100
            }
        }
        return leaderPts
    }
    
    // Returns the number of points for participating in a task
    private func getParticipantPoints(thisTask: Task)-> Int{
        // Get duration of task in seconds / 5
        var participantPts = Int((thisTask.endTimeMilliseconds - thisTask.timeMilliseconds) / 300)
        
        // Set min points at 5
        if participantPts / 2 < 5 {
            participantPts = 5
        }
        // Increased task duration increases point value up to 20
        else {
            participantPts /= 3
            if participantPts < 5 {
                participantPts = 5
            }
            if participantPts > 20 {
                participantPts = 20
            }
        }
        return participantPts
    }
}
