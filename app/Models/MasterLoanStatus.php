<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class MasterLoanStatus extends Model
{
    protected $table='master_loan_status';
    // public $incrementing = false;

    protected $fillable = [
        'id', 'name'
    ];
}
