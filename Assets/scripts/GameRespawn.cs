using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GameRespawn : MonoBehaviour
{
    public float  threshold;

     private void FixedUpdate()
    {
        if(transform.position.y < threshold)
        {
            transform.position = new Vector3(-9.9f, 0.75f, 1.76f);
        }
    }
    
}
