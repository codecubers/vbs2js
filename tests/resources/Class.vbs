Class CAR

    Private m_tires

    Private Sub Class_Initialize()
        m_tires = 4
    End Sub

    Private Sub Class_Terminate()
        Wscrit.Echo "Terminating Class CAR"
    End Sub

    Public Function update(tires)
        m_tires = tires
        update = m_tires
    End Function


End Class ' CAR