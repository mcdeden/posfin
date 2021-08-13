<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class MasterRepaymentStatus extends Model
{
    protected $table='master_repayment_status';
    // public $incrementing = false;

    protected $fillable = [
        'id', 'name'
    ];
}
