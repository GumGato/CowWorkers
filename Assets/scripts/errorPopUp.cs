using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class errorPopUp : MonoBehaviour
{
    public Animator error;
    public Transform player;
    public Transform ErrorBlock;
    void Update()
    {
        float distance = Vector3.Distance(player.position, ErrorBlock.position);
        
        if (distance <= 7)
        {
            error.SetBool("Near", true);
        }
        else
        {
            error.SetBool("Near", false);
        }      
        
    }
}
