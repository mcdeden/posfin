<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class MasterClaimStatus extends Model
{
    protected $table='master_claim_status';
    // public $incrementing = false;

    protected $fillable = [
        'id', 'name'
    ];
}
